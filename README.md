# Tcl Runlog
-------------
a runner's workout logging tool
in tcl/tk with sqlite db
by Tony Baldwin

With runner's pace calculator to calculate pace, calories burned,
and other relevant figures.

![TclRunlog](http://tonybaldwin.me/images/tcltrunlog20150127.jpg)

### TclRunlog requires:
* Tcl/Tk 
* SQLite3 

TclRunlog is cross-platform.
Win and Mac folks, get tcl from http://www.activestate.com/activetcl
and SQLite3 from http://www.sqlite.org

Linux folks, install those with your favorite package manager (apt, yum,
whatever). Make sure you install sqlite3, not sqlite (older, incompatible
version, still available on Debian and some other repos, but sqlite3 is also
available).

I may eventually package this up for win folks in tclkit so you'll just have an executable binary.

Released according to the Gnu Public License v.3 or later.

Wiki: http://wiki.tonybaldwin.me/doku.php/hax/tclrunlog

## UPDATES
-----------------------------------------------------------
** Sat Feb 15 22:23:00 EST 2014 **

TclRunlog will now post to a redmatrix channel.

See author's runlog channel at https://tonybaldwin.info/channel/runlog

### TODO: 
* Save year/month reports to db, export to plain text or other formats,
* posting of workouts, reports, to friendica, wordpress, livejournal, and other networks (possibly); 
* Full text search of entries (setup in db, not in gui).
* Comparison with $thisdate - 1 year?
* The possibilities are endless.

### ACKNOWLEDGMENTS:
This program would not exist were it not for the kind and 
thorough assistance of the tcl/tk community, 
especially http://wiki.tcl.tk and the
irc channel #tcl on freenode.

