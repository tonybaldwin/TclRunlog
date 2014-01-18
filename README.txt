Tcl Runlog
-------------
a runner's workout logging tool
in tcl/tk with sqlite db
by Tony Baldwin

With runner's pace calculator to calculate pace, calories burned,
and other relevant figures.

TclRunlog requires:
Tcl/Tk 
SQLite3 

TclRunlog is cross-platform.
Win and Mac folks, get tcl from http://www.activestate.com/activetcl
and SQLite3 from http://www.sqlite.org

Linux folks, install those with your favorite package manager (apt, yum,
whatever). Make sure you install sqlite3, not sqlite (older, incompatible
version, still available on Debian and some other repos, but sqlite3 is also
available).

I may eventually package this up for win folks in tclkit so you'll just have an executable binary.

Released according to the Gnu Public License v.3 or later.

Wiki: http://wiki.tonybaldwin.info/doku.php?id=hax:tclrunlog

UPDATE 
Sat Jan 18 00:29:54 EST 2014
TclRunlog now creates monthly reports.
It doesn't save them, yet.
Yearly reports will come probably before the weekend is out,
as well as saving both, export to plain txt or other formats (pdf?),
and posting to Friendica or other networks.

TODO: 
Well, the above completion of monthly/yearly report functions, 
plus:
Open and edit existing workout entries - VERY IMPORTANT
Searching entries.
Then from there, who knows...weekly reports?
Comparison with $thisdate - 1 year?
The possibilities are endless.

ACKNOWLEDGMENTS:
This program would not exist were it not for the kind and 
thorough assistance of the tcl/tk community, 
especially http://wiki.tcl.tk and the
irc channel #tcl on freenode.

