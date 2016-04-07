import gyp.common
import gyp.input
import os

DEFS = {
    'COVERAGE': 0,
    'INTERMEDIATE_DIR': 'out/cur',
    'MACOSX_VERSION': '10.11',
    'BUNDLED_DISCID': 1,
    'BUNDLED_FLAC': 1,
    'BUNDLED_LAME': 1,
    'BUNDLED_MAD': 1,
    'BUNDLED_MB5': 1,
    'BUNDLED_MP4V2': 1,
    'BUNDLED_NEON': 1,
    'BUNDLED_OGG': 1,
    'BUNDLED_VORBIS': 1,
    'OS': gyp.common.GetFlavor({}),
}

GENERATOR_INPUT_INFO = {
    'path_sections': [],
    'generator_filelist_paths': None,
    'generator_supports_multiple_toolsets': False,
    'extra_sources_for_rules': [],
    'generator_wants_static_library_dependencies_adjusted': False,
    'non_configuration_keys': [],
}

INCLUDES=["defaults.gypi"]


def FlagsForFile(f):
    _, ext = os.path.splitext(f)
    gyp_file = find_gyp(f)
    root = os.path.dirname(gyp_file)
    flat_list, targets, data = gyp.input.Load(
            build_files=[gyp_file], variables=DEFS, includes=INCLUDES,
            depth=root, generator_input_info=GENERATOR_INPUT_INFO,
            check=False, circular_check=True, duplicate_basename_check=True,
            parallel=False, root_targets={})

    # Find a target that includes `f` and grab its configurations.
    # If we can't find anything, no flags.
    configs = None
    for k, v in targets.iteritems():
        gyp_file = k.split(":")[0]
        gyp_root = os.path.dirname(gyp_file)
        rel_f = os.path.relpath(f, gyp_root)
        if rel_f in v.get("sources", []):
            configs = v["configurations"]
            break
    if configs is None:
        return {}

    # Prefer a configuration named "dev" or "Default" if there is one.
    for key in ["dev", "Default", next(iter(configs))]:
        if key in configs:
            config = configs[key]
            break

    flags = []
    flags.extend(config.get("cflags", []))
    if ext in [".hpp", ".cpp", ".hh", ".cc", ".hxx", ".cxx"]:
        flags.extend(config.get("cflags_cc", []))
    else:
        flags.extend(config.get("cflags_c", []))
    flags.extend("-I" + os.path.join(gyp_root, x) for x in config.get("include_dirs", []))
    flags.extend("-D" + x for x in config.get("defines", []))
    if DEFS["OS"] == "mac":
        sdk = config.get("xcode_settings", {}).get("SDKROOT")
        if not sdk:
            sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk"
        flags.extend(["-isysroot", sdk])

    return {
        "flags": flags,
        "do_cache": True,
    }


def find_gyp(f):
    f = os.path.abspath(f)
    dirname = os.path.dirname(f)
    while dirname != "/":
        if os.path.isdir(os.path.join(dirname, ".git")):
            gyps = [x for x in os.listdir(dirname) if x.endswith(".gyp")]
            if len(gyps) == 1:
                return os.path.join(dirname, gyps[0])
            return None
        dirname = os.path.dirname(dirname)
        if dirname == "/":
            break
    return None


def main(args):
    import json
    for i, a in enumerate(args[1:]):
        if len(args) > 2:
            if i > 0:
                print
        flags = FlagsForFile(a)
        flags = json.dumps(flags, indent=2, separators=(",", ": "))
        if len(args) > 2:
            flags = "%s: %s" % (a, flags)
        print "\n  ".join(flags.split("\n"))


if __name__ == "__main__":
    import sys
    main(sys.argv)
