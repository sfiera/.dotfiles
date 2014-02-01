#!/usr/bin/env python

def decode(folder):
    folder = folder.replace("&", "+")
    folder = folder.replace(",", "/")
    return folder.decode("utf-7")

FOLDERS = {
    u"INBOX": "inbox",
    u"[Gmail]/All Mail": "all",
    u"[Gmail]/Drafts": "drafts",
    u"[Gmail]/Important": "important",
    u"[Gmail]/Sent Mail": "sent",
    u"[Gmail]/Starred": "starred",
    u"\u2190": "labels/left",
    u"\u2318": "labels/command",
    u"\u238b": "labels/escape",
    u"\u25b6": "labels/play",
    u"\u2600": "labels/sun",
    u"\u2601": "labels/cloud",
    u"\u2605": "labels/star",
    u"\u2663": "labels/club",
    u"\u2665": "labels/heart",
    u"\u266b": "labels/music",
    u"\u26e9": "labels/torii",
    u"\u2b07": "labels/down",
    u"\uff04": "labels/dollar",
}

def folderfilter(folder):
    return decode(folder) in FOLDERS

def nametrans(folder):
    return FOLDERS[decode(folder)]
