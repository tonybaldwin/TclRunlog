#!/usr/bin/env wish8.5

# runlog.tcl - a runner's workout log
# in tcl/tk by tony baldwin | http://wiki.tonybaldwin.info

package require Tk
package require Ttk
package require sqlite3

global uname
global units
global oweight
global os
global browser

set os $tcl_platform(os)

bind . <Control-n> {new}
bind . <Escape> {exit}
bind . <F8> {preferences}

image  create  photo  tclrunlog -format GIF -file  tclrunlog.gif
image  create  photo  tricon -format GIF -file  tricon.gif

if { [file exists runlog.db] == 0 } {
	wm title . "TclRunlog"
	frame .msg
	grid [tk::message .msg.em -width 400 -text "ERROR! No Database!\nIf this is your first time running TclRunlog,\nit can create a new database,\nor, You can abort and seek assistance."]
	frame .btns
	grid [ttk::button .btns.egdb -text "Create NEW DB" -command {createdb}]\
	[ttk::button .btns.abort -text "Abort" -command {
	toplevel .abort1
	wm title .abort1 "Aborting"
	grid [tk::message .abort1.msg -width 400 -text "TclRunlog will now exit.\nIf you require assistance, please see the TclRunlog wiki\nhttp://tonyb.us/tclrunlog\nwhere you can find documentation, or contact the author, Tony."]
	grid [ttk::button .abort1.btn -text "Okay" -command {destroy .}]

}]
	pack .msg -in . -side top -fill x
	pack .btns -in . -side top -fill x
} else { 
sqlite3 db runlog.db
set uname [ db eval {select value from config where var="name"}]
set units [ db eval {select value from config where var="units"}]
set oweight [ db eval {select value from config where var="oweight"}]
set browser [ db eval {select value from config where var="browser"}]

wm title . "Tcl Runlog"

frame .menu -relief raised

ttk::menubutton .menu.file -text "File" -menu .menu.file.menu
ttk::menubutton .menu.help -text "Help" -menu .menu.help.menu

menu .menu.file.menu -tearoff 0
.menu.file.menu add command -label "New Workout" -command {new} -accelerator Ctrl-n
.menu.file.menu add command -label "Open Workout" -command {openwk} -accelerator Ctrl-o
.menu.file.menu add command -label "Monthly Report" -command {month} -accelerator Ctrl-m
.menu.file.menu add command -label "Yearly Report" -command {year} -accelerator Ctrl-y
.menu.file.menu add command -label "Preferences" -command {preferences} -accelerator <F8>
.menu.file.menu add command -label "Quit" -command {exit} -accelerator Esc

menu .menu.help.menu -tearoff 0
.menu.help.menu add command -label "About" -command {about}
.menu.help.menu add command -label "Wiki" -command {wiki}

tk::label .menu.icon -image tricon

frame .img
grid [ttk::label .img.icon -image tclrunlog]

pack .menu.file -in .menu -side left
pack .menu.icon -in .menu -side left
pack .menu.help -in .menu -side right
pack .menu -in . -fill x
pack .img -in . -side bottom -fill both
}

proc new {} {
	destroy .img
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
}

proc month {} {
}

proc year {} {
}

proc preferences {} {
	toplevel .prefs
	grid [ttk::label .prefs.ml -text "Units: "]\
	[ttk::combobox .prefs.units -width 13 -value [list "Metric" "English" ] -state readonly -textvar units]
	grid [ttk::label .prefs.nm -text "Name: "]\
	[ttk::entry .prefs.name -width 15 -textvar uname]
	grid [ttk::label .prefs.low -text "Starting weight: "]\
	[ttk::entry .prefs.eow -width 15 -textvar oweight]
	grid [ttk::button .prefs.brzr -text "Browser:" -command {setbrowser}]\
	[ttk::entry .prefs.browz -width 15 -textvar browser]
	grid [ttk::button .prefs.save -text "Save" -command {saveprefs}]\
	[ttk::button .prefs.cancel -text "Close" -command {destroy .prefs}]
}

proc saveprefs {} {
	if { $::units == "English" } {
		sqlite3 db runlog.db 
		db eval {delete from config where var="units"}
		db eval {insert into config values('units','English')}
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
	db eval {delete from config where var="browser"}
	db eval {insert into config values('browser',$::browser)}

}

proc setbrowser {} {
	set filetypes " "
	if { $::os == "Windows NT" } {
	set ::browser [tk_getOpenFile -filetypes $filetypes -initialdir "C:\\Program Files\\"]
	} else {
	if { $::os == "Linux" } {
	set ::browser [tk_getOpenFile -filetypes $filetypes -initialdir "/usr/bin"]
	} else {
	set ::browser [tk_getOpenFile -filetypes $filetypes]
	}
	}
}

proc swout {} {
	set ::note [.new.note.t get 1.0 {end -1c}]
	set tsex [expr { ($::hrs*3600)+($::mins*60)+$::sex }]

	sqlite3 db runlog.db
	db eval {insert into workouts values($::date,$::distance,$::hrs,$::mins,$::sex,$::weight,$::note)}
}

proc about {} {
	toplevel .about 
	wm title .about "About Tcl Runlog"
	tk::message .about.t -text "Tcl Runlog\nA runner's workout log management tool by Tony Baldwin- http://tonyb.us/tclrunlog\nThis program is Free Software, released according to the GPL v.3 or later." -width 200 
	tk::button .about.ok -text "Okay" -command {destroy .about}
	pack .about.t -in .about -side top
	pack .about.ok -in .about -side top
}

proc wiki {} {
	eval exec "\"$::browser\" http://tonyb.us/tclrunlog"
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

