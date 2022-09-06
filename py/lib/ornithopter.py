#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Ornithopter: command-line parsing for birds.

Example:

    integers = []
    log = sys.stdout

    progname, opts = ornithopter.parse()
    for opt, value in opts:
        if opt:
            if opt in ["-h", "--help"]:
                print(help_string)
                return
            elif opt in ["--log"]:
                log = open(value(), "w")
            else:
                raise ornithopter.InvalidOption(opt)
            continue
        integers.append(int(value()))

    args.log.write("%s\\n" % sum(integers))
    args.log.close()
"""

from __future__ import absolute_import, division, print_function, unicode_literals

import os
import sys


def parse(args=None):
    """Returns (progname, opts) where opts generates (option, value)

    For each option or argument in the command-line specified by `args`
    (default sys.argv), a pair (option, value) is yielded. For options,
    `option` is the short or long name of the option parsed (such as
    "-o" or "--option"). For arguments, `option` is None. In both cases,
    `value` is a callable that returns the value of the option or
    argument.
    """
    if args is None:
        args = sys.argv
    return os.path.basename(args[0]), _Ornithopter(args).parse()


class _Ornithopter(object):
    def __init__(self, args):
        if isinstance(args[0], bytes):
            args = [arg.decode("utf-8") for arg in args]
        self.args = args

    def parse(self):
        self.narg = 1
        while self.narg < len(self.args):
            arg = self.args[self.narg]
            self.value = None
            if arg == "--":
                break  # -- stops option parsing
            if arg[:2] == "--":
                split = arg.split("=", 1)
                if len(split) == 2:  # --option=value
                    option, value = split
                    yield option, self.use_long_value
                    if self.value is None:
                        raise UsageError("option %s: no argument permitted" % option)
                else:  # --option; --option value
                    self.value = None
                    yield arg, self.find_long_value
            elif (arg[:1] == "-") and arg[1:]:  # -abco; -abcovalue; -abco value
                self.nch = 1
                while self.nch < len(arg):
                    yield "-" + arg[self.nch], self.find_short_value
                    self.nch += 1
            else:  # -, argument
                yield None, self.use_arg
            self.narg += 1

        # arguments after --
        for narg in range(self.narg + 1, len(self.args)):
            self.value = None
            self.narg = narg
            yield None, self.use_arg

    def use_long_value(self, conv=None):
        if self.value is None:
            arg = self.args[self.narg]
            option, value = arg.split("=", 1)
            name = f"option {option}"
            self.value = self._convert(name, value, conv)
        return self.value

    def use_arg(self, conv=None):
        if self.value is None:
            value = self.args[self.narg]
            name = "arg"
            self.value = self._convert(name, value, conv)
        return self.value

    def find_long_value(self, conv=None):
        if self.value is None:
            name = f"option {self.args[self.narg]}"
            if self.narg + 1 >= len(self.args):
                raise UsageError(f"{name}: argument required")
            self.narg += 1
            self.value = self._convert(name, self.args[self.narg], conv)
        return self.value

    def find_short_value(self, conv=None):
        if self.value is None:
            arg = self.args[self.narg]
            name = f"option -{arg[self.nch]}"
            if self.nch + 1 < len(arg):  # chars remain in arg
                self.value = self._convert(name, arg[self.nch + 1 :], conv)
                self.nch += len(self.value)
            elif self.narg + 1 < len(self.args):  # args remain in args
                self.narg += 1
                self.value = self._convert(name, self.args[self.narg], conv)
            else:
                raise UsageError(f"{name}: argument required")
        return self.value

    @staticmethod
    def _convert(name, value, conv):
        if conv is None:
            return value
        try:
            return conv(value)
        except Exception as e:
            raise UsageError(f"{name}: {e}")


class UsageError(Exception):
    pass


class InvalidOption(UsageError):
    def __str__(self):
        return "invalid option: %s" % self.args


class InvalidCommand(UsageError):
    def __str__(self):
        return "invalid command: %s" % self.args


class ExtraArgument(UsageError):
    def __str__(self):
        return "extra argument: %s" % self.args


class MissingArgument(UsageError):
    def __str__(self):
        return "missing argument: %s" % self.args


def main():
    progname, opts = parse()
    try:
        integers = []
        accumulate = max
        for opt, value in opts:
            if opt == "--sum":
                accumulate = sum
            elif opt:
                raise InvalidOption(opt)
            else:
                integers.append(value(int))
        if not integers:
            raise MissingArgument("integers")
        print(accumulate(integers))
    except UsageError as e:
        print(f"usage: {progname} [--sum] N [N ...]", file=sys.stderr)
        print(f"{progname}: {e}", file=sys.stderr)
        sys.exit(64)


if __name__ == "__main__":
    main()
