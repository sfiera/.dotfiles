#!/usr/bin/osascript

tell application "System Events"
    tell current user
        set home to (home directory as string)
        set eye to home & ".dotfiles:osx:eye.png"
        set picture path to eye as alias
    end tell

    tell current desktop
        set translucent menu bar to false
    end tell

    tell appearance preferences
        set highlight color to purple
    end tell

    tell dock preferences
        set screen edge to left
        set autohide to true
        set dock size to 1.0
        set magnification to false
    end tell

    tell security preferences
        set automatic login to false
        set require password to wake to true
        set require password to unlock to true
    end tell
end tell
