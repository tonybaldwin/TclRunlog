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

UPDATES
-----------------------------------------------------------
Tue Jan 28 21:00:00 EST 2014
You can now open an existing workout entry and edit it,
however, you will probably want to delete the {brackets} around
the date and notes.
Also, you have to choose a workout to edit BY THE DATE.
If you are one of those dedicated masochists who runs twice or more a day,
this feature will not yet be useful for you...working on it.
You can view entries a month at a time.
I will soon be adding text search so you can identify a workout you wish to open
by content of the notes (route, race, tags you write in the notes then become useful!)
I will probably have export of any report (month, year, workout) to plain text files
shortly, and will start building in posting of workouts and reports to 
libertree, friendica, redmatrix, wordpress, statusnet, livejournal...
anything else? Let me know (nope, not doing facebook, tumblr, twitter, or any other
corporate fascist network).

Sat Jan 18 00:29:54 EST 2014
TclRunlog now creates monthly and yearly reports.
It doesn't save them, yet.
Tue Jan 28 11:30:14 EST 2014
View all entries for a given month
Also, yesterday, properly rounded ave distance, total calories
in monthly/yearly reports.

TODO: 
Save year/month reports to db, export to plain text or other formats,
posting of workouts, reports, to friendica and other networks
plus:
DONE (20140128): Open and edit existing workout entries - VERY IMPORTANT
Searching entries.
Comparison with $thisdate - 1 year?
The possibilities are endless.

ACKNOWLEDGMENTS:
This program would not exist were it not for the kind and 
thorough assistance of the tcl/tk community, 
especially http://wiki.tcl.tk and the
irc channel #tcl on freenode.

