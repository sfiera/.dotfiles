import itertools
import os
import shlex
import subprocess


def FlagsForFile(path):
    """YCM entry hook for gn+ninja projects.

    Copy this file somewhere, load YouCompleteMe into your .vimrc with
    the package manager of your choice, and set it as your global YCM
    configuration:

        let g:ycm_global_ycm_extra_conf = '~/path/to/ycm.py'

    In any repository where you want to use it, create a symlink out/cur
    that points to your actual build directory:

        $ BUILD=dbg
        $ gn gen out/$BUILD
        $ rm -f out/cur
        $ ln -s $BUILD out/cur

    If you don't like linking out/cur, see FlagReader and subclass it.
    """
    return {
        "flags": FlagReader(path).load(),
        "do_cache": True,
    }


class FlagReader(object):
    """Reads completion flags from ninja and gn.

    In the common case, where out/cur is a symlink to your build
    directory, all you need to do is call FlagReader(path).load(). In
    other cases, subclass and override in appropriate places.

    These functions are hooks that you can override for your setup:
      - find_build() -- set root_dir and build_dir for self.path.
      - list_candidate_files() -- suggest alternate files to self.path.
      - source_extensions() -- suggest source extensions for headers.

    If you're writing your own list_candidate_files(), you might be
    interested in these functions:
      - file_from_same_target() - sibling via target 'sources'.
      - file_from_same_directory() - sibling via directory.
      - file_from_label(label) - turns label into relative path.

    Fields:
        path: path to the file we want completion flags for.
        root_dir: path to the top-level directory, //.
        build_dir: path to ninja's build directory.

    All fields are paths relative to $PWD.
    """

    # Flags are mapped through this dictionary before being returned.
    # If a flag is found here, it is replaced by the corresponding list
    # of flags, so mapping to an empty list removes the flag.
    #
    # Can be overridden in subclasses.
    FLAG_MAP = {
        # Blacklisted flags. Not understood by YCM's libclang.
        "-Wno-psabi": [],
        "-Wno-unused-local-typedefs": [],
        "-finline-limit=64": [],
        "-fno-caller-saves": [],
        "-fno-tree-sra": [],
        "-mfloat-abi=softfp": [],
        "-mfpu=neon": [],
        "-mthumb": [],
        "-mthumb-interwork": [],

        # ARMv7 means 32-bit, but otherwise blacklisted.
        "-march=armv7-a": ["-m32"],
    }

    def __init__(self, path):
        """Initializes self.path and finds the build dirs."""
        self.path = path
        self.find_build()

    def load(self):
        """Loads and returns completion flags for self.path."""
        command = self._get_command()
        if not command:
            return []

        flags = (self._rule_flags(command[1:]) +
                 self._executable_flags(command[0]))
        flags = (self.FLAG_MAP.get(f, [f]) for f in flags)
        return list(itertools.chain(*flags))

    def find_build(self):
        """Set self.root_dir and self.build_dir.

        Assumes the existence of and searches for a path out/cur in the
        root directory. In my (sfiera's) setup, I always keep that
        around as a symlink to the actual build directory, somewhere in
        out/, which saves me from having to remember where I'm working
        from at the moment, and allows me to write tools (like this)
        more easily.

        Raises: RuntimeError: build directory not found.
        """
        directory = os.path.dirname(os.path.realpath(self.path))
        while True:
            build_dir = os.path.realpath(_normjoin(directory, "out/cur"))
            if os.path.exists(build_dir):
                break
            if directory == "/":
                raise RuntimeError("can't find build directory")
            directory = os.path.dirname(directory)

        self.root_dir = os.path.relpath(directory, os.getcwd())
        self.build_dir = os.path.relpath(build_dir, os.getcwd())

    def list_candidate_files(self):
        """List files whose compilation flags might work for the file.

        In particular, we are interested in:

          - self.path itself.

          - a sibling of self.path in some target's 'sources' block.
            This is for headers, which should be declared in 'sources'
            but might be in a public header directory instead of next to
            the file itself.

          - a sibling of self.path in its directory. This is for new
            files that might not yet be in BUILD.gn.

        Yields: paths to files, relative to self.build_dir. Might also
            return None; callers should ignore false values.
        """
        yield os.path.relpath(self.path, self.build_dir)
        yield self.file_from_same_target()
        yield self.file_from_same_directory()

    def source_extensions(self):
        """Returns extensions to consider for self.path, if a header.

        Header files aren't compiled, so if self.path has a header's
        extension, we'll want to look at files with the corresponding
        source extensions.

        Returns: a list of extensions, like [".c", ".cpp"].
        """
        _, ext = os.path.splitext(self.path)
        return {
            ".h": [".m", ".cpp", ".cc", ".c"],  # free-for-all!
            ".hh": [".cc"],
            ".hpp": [".cpp"],
        }.get(ext, [ext])

    def file_from_same_target(self):
        """Returns a sibling of self.path in any target's sources.

        Returns: a path, relative to self.build_dir, or None.
        """
        exts = self.source_extensions()
        for target in self._get_gn_targets():
            sources = self._get_gn_sources(target)
            for ext in exts:
                for source in sources:
                    if ext != os.path.splitext(source)[1]:
                        continue
                    if source.startswith("//"):
                        source = self.file_from_label(source)
                    return source
        return None

    def file_from_same_directory(self):
        """Returns a sibling of self.path in its directory.

        Returns: a path, relative to self.build_dir, or None.
        """
        exts = self.source_extensions()
        directory = os.path.dirname(os.path.join(".", self.path))
        sources = os.listdir(directory)
        for ext in exts:
            for source in sources:
                if ext == os.path.splitext(source)[1]:
                    return os.path.relpath(source, self.build_dir)
        return None

    def file_from_label(self, label):
        """Turns a //file/label into a path relative to self.build_dir.

        Requires that the label start with //, otherwise it's not clear
        where it should be relative to.
        """
        assert label.startswith("//")
        source = _normjoin(self.root_dir, label[2:])
        source = os.path.relpath(source, self.build_dir)
        return source

    ####################################################################
    # Private functions

    def _get_command(self):
        """Looks for an appropriate command to build self.path.

        Considers all files from self.list_candidate_files(). If it can
        get an appropriate output and command to build that output from
        ninja, returns it; otherwise returns None.
        """
        for try_path in self.list_candidate_files():
            if not try_path:
                continue
            for target in self._get_file_outputs(try_path):
                command = self._get_target_command(try_path, target)
                if command:
                    return command
        return None

    def _rule_flags(self, args):
        """Returns flags based on the args to a build command.

        These are the flags specific to the build, like warning and
        include flags.
        """
        flags = []
        for flag, value in zip(args, args[1:] + [None]):
            if not flag.startswith("-") or (len(flag) < 2) or (flag == "--"):
                continue  # normal arg
            if flag[1] == "I":
                include_dir = _normjoin(self.build_dir, flag[2:])
                flags.append("-I%s" % include_dir)
            elif (flag[1] in "DFOWfm") or flag.startswith("-std"):
                flags.append(flag)
            elif flag == "-isysroot":
                include_dir = _normjoin(self.build_dir, value)
                flags.extend(["-isysroot", include_dir])
            elif flag.startswith("-isystem"):
                include_dir = _normjoin(self.build_dir, flag[8:])
                flags.extend(["-isystem", include_dir])
            elif flag.startswith("--sysroot="):
                include_dir = _normjoin(self.build_dir, flag[10:])
                flags.append("--sysroot=%s" % include_dir)
        return flags

    def _executable_flags(self, executable):
        """Returns flags based on the executable of a build command.

        These are flags specific to the tool, like system includes
        and framework paths.
        """
        if "/" in executable:
            executable = _normjoin(self.build_dir, executable)
        p = subprocess.Popen(
                [executable, "-x", "c++", "-v", "-E", "/dev/null"],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, _ = p.communicate()
        if p.returncode != 0:
            return []
        _, _, include_text = stdout.partition(
            "\n#include <...> search starts here:\n")
        include_text, _, _ = include_text.partition("\nEnd of search list.\n")
        flags = []
        for line in include_text.split("\n"):
            line = line.strip()
            if line.endswith(" (framework directory)"):
                line, _, _ = line.rsplit(" ", 2)
                flags.extend(["-iframework", line])
            else:
                flags.extend(["-isystem", line.strip()])
        return flags

    def _get_gn_targets(self):
        """Lists targets that list self.path in 'sources'."""
        p = subprocess.Popen(
                ["gn", "refs", self.build_dir, self.path],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, _ = p.communicate()
        if p.returncode != 0:
            return []
        return [x for x in stdout.split("\n") if x]

    def _get_gn_sources(self, target):
        """Lists the gn 'sources' for `target`."""
        p = subprocess.Popen(
                ["gn", "desc", self.build_dir, target],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, _ = p.communicate()
        if p.returncode != 0:
            return []
        _, _, sources_text = stdout.partition("\nsources:\n")
        sources_text, _, _ = sources_text.partition("\n\n")
        return [x.strip() for x in sources_text.split("\n")]

    def _get_file_outputs(self, path):
        """Lists .o or .obj files that ninja generates from `path`."""
        p = subprocess.Popen(
                ["ninja", "-C", self.build_dir, "-t", "query", path],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, _ = p.communicate()
        if p.returncode != 0:
            return
        _, _, outputs_text = stdout.partition("\n  outputs:\n")
        for line in outputs_text.split("\n"):
            if line.endswith(".o") or line.endswith(".obj"):
                yield line.strip()

    def _get_target_command(self, path, target):
        """Gets the last shell command where `target` uses `path`.

        Returns: a command-line call, as a list of strings.
        """
        p = subprocess.Popen(
                ["ninja", "-C", self.build_dir, "-t", "commands", target],
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout, _ = p.communicate()
        if p.returncode != 0:
            return None
        for line in reversed(stdout.split("\n")):
            command = shlex.split(line)
            if path in command:
                return command
        return None


def _normjoin(*args):
    """Joins and normalizes path."""
    return os.path.normpath(os.path.join(*args))


def main(args):
    """Usage: python ycm.vim PATH [...].

    Useful for testing the flags on files."""
    import json
    for i, a in enumerate(args[1:]):
        if (len(args) > 2) and (i > 0):
            print
        flags = FlagsForFile(a)
        flags = json.dumps(flags, indent=2, separators=(",", ": "))
        if len(args) > 2:
            flags = "%s: %s" % (a, flags)
        print flags


if __name__ == "__main__":
    import sys
    main(sys.argv)
