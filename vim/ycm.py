import itertools
import os
import shlex
import subprocess


def FlagsForFile(f):
    return {
        "flags": get_flags(f),
        "do_cache": True,
    }


def get_flags(path):
    root_dir, build_dir = find_build(path)
    command = get_command(root_dir, build_dir, path)
    if not command:
        return []

    return rule_flags(root_dir, build_dir, command[1:]) + executable_flags(command[0])


def get_command(root_dir, build_dir, path):
    path = os.path.relpath(path, build_dir)
    for path in get_candidate_files(root_dir, build_dir, path):
        for target in get_file_outputs(build_dir, path):
            command = get_target_command(build_dir, path, target)
            if command:
                return command
    return None


def rule_flags(root_dir, build_dir, args):
    flags = []
    for flag, value in zip(args, args[1:] + [None]):
        if not flag.startswith("-") or (len(flag) < 2) or (flag == "--"):
            continue  # normal arg
        if flag[1] == "I":
            include_dir = os.path.normpath(os.path.join(build_dir, flag[2:]))
            flags.append("-I%s" % include_dir)
        elif (flag[1] in "DFOWfm") or flag.startswith("-std"):
            flags.append(flag)
        elif flag == "-isysroot":
            include_dir = os.path.normpath(os.path.join(build_dir, value))
            flags.extend(["-isysroot", include_dir])
        elif flag.startswith("-isystem"):
            include_dir = os.path.normpath(os.path.join(build_dir, flag[8:]))
            flags.extend(["-isystem", include_dir])
        elif flag.startswith("--sysroot="):
            include_dir = os.path.normpath(os.path.join(build_dir, flag[10:]))
            flags.append("--sysroot=%s" % include_dir)
    return flags


def executable_flags(executable):
    p = subprocess.Popen([executable, "-x", "c++", "-v", "-E", "/dev/null"],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = p.communicate()
    if p.returncode != 0:
        return []
    _, _, include_text = stdout.partition("\n#include <...> search starts here:\n")
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


def find_build(path):
    directory = os.path.realpath(path)
    while directory != "/":
        directory = os.path.dirname(directory)
        build_dir = os.path.join(directory, "out/cur")
        if os.path.exists(build_dir):
            return (
                os.path.relpath(directory, os.getcwd()),
                os.path.relpath(os.path.realpath(build_dir), os.getcwd()),
            )


def get_candidate_files(root_dir, build_dir, path):
    """List files whose compilation flags might work for the file."""
    # First candidate: the file itself.
    yield path

    # Second candidate: a file in the same target, with a matching
    # extension. This works well if headers and sources are in different
    # locations, like include/ and src/.
    exts = source_extensions(path)
    for target in get_gn_targets(build_dir, path):
        sources = get_gn_sources(build_dir, target)
        for ext in exts:
            try:
                source = next(s for s in sources if ext == os.path.splitext(s)[1])
            except StopIteration:
                continue
            if source.startswith("//"):
                source = os.path.relpath(os.path.join(root_dir, source[2:]), build_dir)
            yield source
            break

    # Third candidate: a file in the same directory. This works well for
    # newly-created files that aren't in build files yet.
    # TODO(sfiera)

    # Fourth candidate: any file?
    # TODO(sfiera)


def source_extensions(path):
    _, ext = os.path.splitext(path)
    return {
        ".h": [".m", ".cpp", ".cc", ".c"],
        ".hh": [".cc"],
        ".hpp": [".cpp"],
    }.get(ext, [ext])


def get_gn_targets(build_dir, path):
    path = os.path.join(build_dir, path)
    p = subprocess.Popen(["gn", "refs", build_dir, path],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = p.communicate()
    if p.returncode != 0:
        return []
    return [x for x in stdout.split("\n") if x]


def get_gn_sources(build_dir, target):
    p = subprocess.Popen(["gn", "desc", build_dir, target],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = p.communicate()
    if p.returncode != 0:
        return []
    _, _, sources_text = stdout.partition("\nsources:\n")
    sources_text, _, _ = sources_text.partition("\n\n")
    return [x.strip() for x in sources_text.split("\n")]


def get_file_outputs(build_dir, path):
    p = subprocess.Popen(["ninja", "-C", build_dir, "-t", "query", path],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = p.communicate()
    if p.returncode != 0:
        return
    _, _, outputs_text = stdout.partition("\n  outputs:\n")
    for line in outputs_text.split("\n"):
        if line.endswith(".o") or line.endswith(".obj"):
            yield line.strip()


def get_target_command(build_dir, path, target):
    p = subprocess.Popen(["ninja", "-C", build_dir, "-t", "commands", target],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, _ = p.communicate()
    if p.returncode != 0:
        return None
    for line in reversed(stdout.split("\n")):
        command = shlex.split(line)
        if path in command:
            return command
    return None


def main(args):
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
