#!/bin/sh

# pdaXrom addon

xmodmap /etc/X11/kb/corgi.xmodmap
xkeymouse &

if [ -f $HOME/Choices/common/backlight ]; then
    setfl `cat $HOME/Choices/common/backlight`
fi

if [ -f $HOME/Choices/common/screenoff ]; then
    xset s `cat $HOME/Choices/common/screenoff`
else
    xset s 180
fi

# This file was created by ROX-Session.

if [ -d ~/bin ]; then
	PATH=${HOME}/bin:${PATH}
fi

# Step 1: Try to run ROX-Session. If it works, stop right here.

if [ -x "/usr/apps/ROX-Session/AppRun" ]; then
	exec "/usr/apps/ROX-Session/AppRun" -w
fi

# Step 2: It didn't work. Try to provide a failsafe login so the user
# can fix things.

# Load a window manager. Keep trying until we find one that works!

for wm in xfwm4 sawfish sawmill enlightenment wmaker icewm blackbox fluxbox \
	metacity kwin kwm fvwm2 fvwm 4Dwm twm; do
  if [ -x "`which $wm`" ]; then break; fi;
done

"$wm" &

xmessage -file - << END
.xsession: failed to run /usr/apps/ROX-Session/AppRun - maybe you moved or deleted it?

I'll try to give you an xterm and a filer window instead - try to find
and run ROX-Session to fix the problem. Close the xterm to logout.

If all else fails, delete your .xsession and .xinitrc files to get the
system defaults.

Report any problems to:
http://rox.sourceforge.net/phpwiki/index.php/MailingLists

Good luck!
END
rox &
exec xterm
