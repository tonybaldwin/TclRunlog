#!/usr/bin/env wish8.5

# runlog.tcl - a runner's workout log
# in tcl/tk by tony baldwin | http://wiki.tonybaldwin.info

# require stuff we need
package require Tk
package require Ttk
package require sqlite3

# initialize some important variables
global uname
global units
global oweight

# oh! Keybindings!
bind . <Control-n> {new}
bind . <Escape> {exit}

# get some important variables from the DB
sqlite3 db runlog.db
set uname [ db eval {select value from config where var="name"}]
set units [ db eval {select value from config where var="units"}]
set oweight [ db eval {select value from config where var="oweight"}]

# Are we building the GUI already?
# Yep...
#
wm title . "Tcl Runlog"

frame .title 
grid [ttk::label .title.t -text "Tcl Runlog"]
pack .title -in . -fill x

frame .menu -relief raised

ttk::menubutton .menu.file -text "File" -menu .menu.file.menu
ttk::menubutton .menu.help -text "Help" -menu .menu.help.menu

menu .menu.file.menu -tearoff 0
.menu.file.menu add command -label "New Workout" -command {new} -accelerator Ctrl-n
.menu.file.menu add command -label "Open Workout" -command {openwk} -accelerator Ctrl-o # TODO
.menu.file.menu add command -label "Monthly Report" -command {month} -accelerator Ctrl-m # TODO
.menu.file.menu add command -label "Yearly Report" -command {year} -accelerator Ctrl-y # TODO
.menu.file.menu add command -label "Preferences" -command {preferences} 
.menu.file.menu add command -label "Quit" -command {exit} -accelerator Esc

menu .menu.help.menu -tearoff 0
.menu.help.menu add command -label "About" -command {about}
.menu.help.menu add command -label "Wiki" -command {wiki}

pack .menu.file -in .menu -side left
pack .menu.help -in .menu -side right
pack .menu -in . -fill x

# enter a new workout entry 
proc new {} {
	frame .new
	frame .new.date

	grid [ttk::label .new.date.ldate -text "Date: "]\
	[ttk::entry .new.date.edate -textvar date]\
	[ttk::button .new.date.cdate -text "Current Date" -command {
	set date [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	}]

	frame .new.dist
	grid [ttk::label .new.dist.ldist -text "Distance: "]\
	[ttk::entry .new.dist.edist -width 5 -textvar distance]\
	[ttk::label .new.dist.lw -text "Weight: "]\
	[ttk::entry .new.dist.ew -width 5 -textvar weight]

	grid [ttk::label .new.dist.ltime -text "Time: "]

	frame .new.time
	grid [ttk::label .new.time.lhrs -text "hours: "]\
	[ttk::entry .new.time.ehrs -width 5 -textvar hrs]\
	[ttk::label .new.time.lmins -text "minutes: "]\
	[ttk::entry .new.time.emins -width 5 -textvar mins]\
	[ttk::label .new.time.lsex -text "seconds: "]\
	[ttk::entry .new.time.esex -width 5 -textvar sex]

	grid [ttk::label .new.time.note -text "Notes: "]

	frame .new.note
	text .new.note.t -width 35 -height 10 -wrap word -yscrollcommand ".new.note.ys set"
	scrollbar .new.note.ys -command ".new.note.t yview"
	pack .new.note.t -in .new.note -side left -fill both
	pack .new.note.ys -in .new.note -side left -fill y

	frame .new.btns
	grid [ttk::button .new.btns.svwk -text "Save" -command {swout}]\
	[ttk::button .new.btns.close -text "Close" -command {destroy .new}]

	pack .new -in . -side bottom
	pack .new.date -in .new -side top -fill x
	pack .new.dist -in .new -side top -fill x
	pack .new.time -in .new -side top -fill x
	pack .new.note -in .new -side top -fill x
	pack .new.btns -in .new -side top -fill x
}

proc openwk {} {
	#WTF? Not going to work without some code in here! TODO
}

proc month {} {
	#WTF? Not going to work without some code in here! TODO
}

proc year {} {
	#WTF? Not going to work without some code in here! TODO
}

proc preferences {} {
	# units, starting weight for weight tracking, user's name...
	# probably more stuff we want to put in here.
	# especially when we build in the parts to post workouts to
	# blogs, friendica, redmatrix, etc.
	# since we'll need usernames and passwords and shite...
	toplevel .prefs
	grid [ttk::label .prefs.ml -text "Units: "]\
	[ttk::combobox .prefs.units -width 12 -value [list "Metric" "English" ] -state readonly -textvar units]
	grid [ttk::label .prefs.nm -text "Name: "]\
	[ttk::entry .prefs.name -width 15 -textvar uname]
	grid [ttk::label .prefs.low -text "Starting weight: "]\
	[ttk::entry .prefs.eow -width 15 -textvar oweight]
	grid [ttk::button .prefs.save -text "Save" -command {saveprefs}]\
	[ttk::button .prefs.cancel -text "Close" -command {destroy .prefs}]
}

proc saveprefs {} {
	# saving the preferences/config stuff to the config table in the DB.
	if { $::units == "English" } {
		sqlite3 db runlog.db 
		db eval {delete from config where var="units"}
		db eval {insert into config values('units','English')}
		# db1 eval {INSERT INTO t1 VALUES(5,@bigstring)} 
		db close
	} else { 
		sqlite3 db runlog.db 
		db eval {delete from config where var="units"}
		db eval {insert into config values('units','Metric')}
		db close
	}
	
	sqlite3 db runlog.db
	db eval {delete from config where var="name"}
	db eval {insert into config values('name',$::uname)}
	db eval {delete from config where var="oweight"}
	db eval {insert into config values('oweight',$::oweight)}

}

proc swout {} {
	# saving a new workout to the DB.
	set ::note [.new.note.t get 1.0 {end -1c}]
	# oh, look...I started to crunch numbers to calculate the pace
	# and didn't finish! Enough hacking for today
	# TODO!! (like 7 dozen other things on the TODO list).
	set tsex [expr { ($::hrs*3600)+($::mins*60)+$::sex }

	sqlite3 db runlog.db
	db eval {insert into workouts values($::date,$::distance,$::hrs,$::mins,$::sex,$::weight,$::note)}
	# okay, we ARE going to crunch nos., give the user their (approx.) calories burned,
	# and their pace (min/unit, like min/mile or min/km, depending on English/Metric units preference).
}

proc about {} {
	# no comment necessary...this is self-explanatory.
	# I mean, even I can tell what it's doing!
	# Must be simple.
	toplevel .about 
	wm title .about "About Tcl Runlog"
	tk::message .about.t -text "Tcl Runlog\nA runner's workout log management tool by Tony Baldwin- http://wiki.tonybaldwin.info\nThis program is Free Software, released according to the GPL v.3 or later." -width 200 
	tk::button .about.ok -text "Okay" -command {destroy .about}
	pack .about.t -in .about -side top
	pack .about.ok -in .about -side top
}

proc wiki {} {
	# haven't even built the browser preference into preferences.
	# must do that...then delete this comment...
	# TODO!!
	# But this will be to open the wiki page in the user's browser,
	# so they can get help, directions, read faq, read manual...
	# when we have a faq and/or manual, etc., which we don't, yet.
	eval exec "\"$::browser\" http://wiki.tonybaldwin.info/doku.php?id=hax:tclrunlog"
}


# This program was written by tony baldwin - http://wiki.tonybaldwin.info 
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

