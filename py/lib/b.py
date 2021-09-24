#!/usr/bin/env python3

from __future__ import absolute_import, division, print_function, unicode_literals

import collections
import ornithopter
import os
import re
import shlex
import subprocess
import sys


class CommandError(Exception):
    pass


def main():
    COMMANDS = {
        "-A": all_overview,
        "-a": attach,
        "-c": create,
        "-n": no_attach,
        "-m": move,
        "-d": delete,
        "-D": delete_hard,
    }

    try:
        progname, args = ornithopter.parse()
        cmd, val = None, None
        branches = []
        for opt, value in args:
            if opt in COMMANDS:
                if cmd:
                    raise ornithopter.UsageError("got both %s and %s" % (cmd, opt))
                cmd = opt
                if opt in {"-c", "-n", "-m"}:
                    val = value()
            elif opt:
                raise ornithopter.InvalidOption(opt)
            else:
                branches.append(value())
        if cmd:
            if val is None:
                COMMANDS[cmd](branches)
            else:
                COMMANDS[cmd](val, branches)
        elif branches:
            attach(branches)
        else:
            overview()
    except CommandError as e:
        sys.stderr.write("%s: %s\n" % (progname, e))
        sys.exit(1)
    except ornithopter.UsageError as e:
        sys.stderr.write("%s: %s\n" % (progname, e))
        sys.stderr.write("".join([
            "usage: {progname} [-A]\n",
            "       {progname} [-a] BRANCH\n",
            "       {progname} -c NEW [OLD]\n",
            "       {progname} -n NEW [OLD]\n",
            "       {progname} -m NEW [OLD]\n",
            "       {progname} -d BRANCH…\n",
            "       {progname} -D BRANCH…\n",
        ]).format(progname=progname))
        sys.exit(64)
    except subprocess.CalledProcessError as e:
        sys.exit(e.returncode)


def call(command):
    return subprocess.call(command) == 0


def tint(color, s):
    return "\033[38;5;%dm%s\033[0m" % (color, s)


def width(s):
    return len(re.subn(r"\033\[[0-9;]*m", "", s)[0])


def ljust(s, w):
    w -= width(s)
    return s + (" " * w)


red = lambda s: tint(1, s)
green = lambda s: tint(2, s)
yellow = lambda s: tint(3, s)
dim = lambda s: tint(10, s)


class Branch(object):
    def __init__(self, name, short):
        self.name = name
        self.short = short
        self.is_head = False
        self.hash = None
        self.hash_short = None
        self.ahead = 0
        self.behind = 0
        self.children = {}
        self.root = True


def append_branch_lines(branches, branch, prefix, head_color):
    if branch.is_head:
        name = "* " + head_color(branch.short)
    else:
        name = "  " + branch.short
    ahead = green("+%d" % branch.ahead) if branch.ahead else ""
    behind = red("-%d" % branch.behind) if branch.behind else ""

    try:
        upload = subprocess.check_output(
            ["git", "rev-parse", "github/%s" % branch.short],
            stderr=subprocess.DEVNULL).decode("utf-8").strip()
    except subprocess.CalledProcessError:
        upload = ""
    if upload == branch.hash:
        upload = green("✓")
    elif upload:
        upload = red("x")

    branches.append((prefix + name, upload, ahead, behind, dim(branch.hash_short or "")))
    for _, child in sorted(branch.children.items()):
        append_branch_lines(branches, child, prefix + "  ", head_color)


def get_head_color():
    color = green
    files = subprocess.check_output("git status --porcelain".split()).decode("utf-8")
    for line in files.splitlines():
        color = yellow
        if line[1] != " ":
            color = red
            break
    return color


def overview(refs="refs/heads"):
    head_color = get_head_color()

    refs = subprocess.check_output([
        "git", "for-each-ref", "--shell", "--format=" + " ".join("%%(%s)" % field for field in [
            "HEAD", "refname", "refname:short", "upstream", "upstream:short",
            "upstream:track,nobracket", "objectname", "objectname:short"
        ]), refs
    ])
    branches = {}
    for ref in refs.splitlines():
        head, ref, ref_short, up, up_short, up_track, hash, hash_short = shlex.split(
            ref.decode("utf-8"))

        if ref_short not in branches:
            branches[ref_short] = Branch(ref, ref_short)
        branch = branches[ref_short]
        branch.hash = hash
        branch.hash_short = hash_short
        branch.is_head = (head == "*")

        if up:
            if up_short not in branches:
                branches[up_short] = Branch(up, up_short)
            up = branches[up_short]
            up.children[ref_short] = branch
            branch.root = False

            ahead_behind = re.match(r"^(?:ahead (\d*))?[, ]*(?:behind (\d*))?$", up_track)
            if ahead_behind:
                ahead, behind = ahead_behind.groups()
                branch.ahead = int(ahead or 0)
                branch.behind = int(behind or 0)
            else:
                branch.ahead, branch.behind = 0, 0

    lines = []
    for _, branch in sorted(branches.items()):
        if branch.root:
            append_branch_lines(lines, branch, "", head_color)

    widths = [max(map(width, s)) for s in zip(*lines)]
    for line in lines:
        print(" ".join(ljust(s, w) for s, w in zip(line, widths)))


def all_overview(branches):
    if branches:
        raise ornithopter.UsageError("-A takes no branches")
    overview("refs")


def is_branch(branch):
    return call(["git", "show-ref", "--quiet", "--verify", "refs/heads/%s" % branch])


def attach(branches):
    if len(branches) < 1:
        raise ornithopter.UsageError("need a branch")
    elif len(branches) > 1:
        raise ornithopter.UsageError("too many branches")
    branch, = branches
    if not is_branch(branch):
        raise CommandError("%s: branch not found" % branch)
    subprocess.check_call(["git", "freeze"])
    subprocess.check_call(["git", "checkout", branch])
    subprocess.check_call(["git", "thaw"])


def create(name, branches):
    if len(branches) > 1:
        raise ornithopter.UsageError("too many branches")
    command = ["git", "checkout", "-b", name] + branches
    subprocess.check_call(command)


def no_attach(name, branches):
    if len(branches) > 1:
        raise ornithopter.UsageError("too many branches")
    command = ["git", "branch", "--", name] + branches
    subprocess.check_call(command)


def move(name, branches):
    if len(branches) > 1:
        raise ornithopter.UsageError("too many branches")
    command = ["git", "branch", "-m", "--"] + branches + [name]
    subprocess.check_call(command)


def delete(branches):
    command = ["git", "branch", "-d", "--"] + branches
    subprocess.check_call(command)


def delete_hard(branches):
    command = ["git", "branch", "-D", "--"] + branches
    subprocess.check_call(command)


if __name__ == "__main__":
    main()
