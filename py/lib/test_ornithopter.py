#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import ornithopter


def run(args):
    integers = []

    progname, opts = ornithopter.parse(args)
    for opt, value in opts:
        if opt:
            if opt in ["-h", "--help"]:
                print(help_string)
                return
            else:
                raise ornithopter.InvalidOption(opt)
            continue
        integers.append(value(int))

    return progname, sum(integers)


def test_run():
    progname, result = run(["bin/test_ornithopter", "1", "2"])
    assert progname == "test_ornithopter"
    assert result == 3


def test_convert_fail():
    threw_usage_error = False
    try:
        progname, result = run(["bin/test_ornithopter", "1", "two"])
    except ornithopter.UsageError as e:
        assert str(e) == "arg: invalid literal for int() with base 10: 'two'"
        threw_usage_error = True
    assert threw_usage_error
