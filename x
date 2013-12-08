--- /dev/null	2013-11-25 18:32:15.478221133 +0900
+++ /etc/lirc/lircrc	2013-12-08 15:12:53.942260883 +0900
@@ -0,0 +1,100 @@
+# knobmute
+# knobvol-
+# knobvol+
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = knobvol-
+    repeat = 1
+    config = mpc volume -- -6
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = knobvol+
+    repeat = 1
+    config = mpc volume -- +6
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = knobmute
+    config = mpc -q toggle
+end
+
+# vol+
+# vol-
+# mute
+# power
+# menu/back
+# menu/back-long
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = vol-
+    repeat = 1
+    config = mpc volume -- +6
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = vol+
+    repeat = 1
+    config = mpc volume -- -6
+end
+
+# up
+# down
+# left
+# right
+# ok
+
+# repeat
+# shuffle
+# return
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = repeat
+    config = mpc -q repeat
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = shuffle
+    config = mpc -q random
+end
+
+# bb
+# bb-long
+# play-pause
+# ff
+# ff-long
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = bb
+    config = mpc -q prev
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = play-pause
+    config = mpc -q toggle
+end
+
+begin
+    prog = irexec
+    remote = RM-820
+    button = ff
+    config = mpc -q next
+end
