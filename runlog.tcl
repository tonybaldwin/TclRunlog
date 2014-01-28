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
global pace
global cals
global dunit
global pace
global cals
global month
global year
global ymo

set year [clock format [clock seconds] -format %Y]
set month [clock format [clock seconds] -format %m]

set cals {}
set pace {}

set os $tcl_platform(os)

bind . <Control-n> {new}
bind . <Escape> {exit}
bind . <F8> {preferences}
bind . <F4> {eval exec wish pacecalc.tcl}
bind . <Control-m> {month}
bind . <Control-y> {year}

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

if { $units == "English" } {
	set dunit "mi"
	} elseif {
	$units == "Metric" 
	} { set dunit "km"
}

wm title . "Tcl Runlog"

frame .menu -relief raised

ttk::menubutton .menu.file -text "File" -menu .menu.file.menu
ttk::menubutton .menu.help -text "Help" -menu .menu.help.menu

menu .menu.file.menu -tearoff 0
.menu.file.menu add command -label "New Workout" -command {new} -accelerator Ctrl-n
.menu.file.menu add command -label "Open Workout" -command {openwk} -accelerator Ctrl-o
.menu.file.menu add command -label "Monthly Report" -command {month} -accelerator Ctrl-m
.menu.file.menu add command -label "Yearly Report" -command {year} -accelerator Ctrl-y
.menu.file.menu add command -label "Run Calculator" -command {
	eval exec wish pacecalc.tcl &
} -accelerator <F4>
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

	frame .new.calc
	grid [ttk::button .new.calc.calc -text "Calculate" -command {newcalc}]
	grid [ttk::label .new.calc.pc -text "Pace: (min/$::dunit): "]\
	[ttk::entry .new.calc.pace -width 5 -textvar pace]
	grid [ttk::label .new.calc.clr -text "Calories: "]\
	[ttk::entry .new.calc.cals -width 5 -textvar cals]

	grid [ttk::label .new.calc.note -text "Notes: "]

	frame .new.note
	text .new.note.t -width 35 -height 10 -wrap word -yscrollcommand ".new.note.ys set"
	scrollbar .new.note.ys -command ".new.note.t yview"
	pack .new.note.t -in .new.note -side left -fill both
	pack .new.note.ys -in .new.note -side left -fill y

	frame .new.btns
	grid [ttk::button .new.btns.svwk -text "Save" -command {swout}]\
	[ttk::button .new.btns.close -text "Close" -command {
		destroy .new
		frame .img
		grid [ttk::label .img.icon -image tclrunlog]
		pack .img -in . -side bottom -fill both
	}]\
	[ttk::button .new.btns.clr -text "Clear" -command {
		set wkvars [list distance date weight hrs mins sex pace cals note]	
		foreach var $::wkvars {global $var}
		foreach var $::wkvars {set $var " "}
		.new.note.t delete 1.0 end
	}]

	pack .new -in . -side bottom
	pack .new.date -in .new -side top -fill x
	pack .new.dist -in .new -side top -fill x
	pack .new.time -in .new -side top -fill x
	pack .new.calc -in .new -side top -fill x
	pack .new.note -in .new -side top -fill x
	pack .new.btns -in .new -side top -fill x
}

proc openwk {} {
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

proc newcalc {} {

	if { $::sex != "00" } {
	set seconds [ string trimleft $::sex 0 ]
	} else { set seconds $::sex }
	if { $::hrs != "00" } {
	set hours [ string trimleft $::hrs 0 ]
	} else { set hours $::hrs }
	if { $::mins != "00" } {
	set minutes [ string trimleft $::mins 0 ]
	} else { set minutes $::mins }
	set tsex [expr { ($hours*3600)+($minutes*60)+$seconds }]
	set pacesecs [expr { $tsex / $::distance }]
	set pacesex [expr {round($pacesecs)}]
	set ::pace [clock format $pacesex -gmt 1 -format %M:%S]
	

	set ::cals [expr {0.7568 * $::weight * $::distance}]
	set ::cals [expr {round($::cals)}]
}
proc swout {} {
	set ::note [.new.note.t get 1.0 {end -1c}]
	sqlite3 db runlog.db
	db eval {insert into workouts values($::date,$::distance,$::hrs,$::mins,$::sex,$::pace,$::weight,$::cals,$::note)}
	set wchange [expr {$::weight - $::oweight}]
	toplevel .wout
	wm title .wout "Workout $::date"
	bind .wout <Escape> {destroy .wout}
	text .wout.t -width 40 -height 10
	set wtxt "$::uname's Workout $::date\n\nDistance: $::distance\nTime: $::hrs:$::mins:$::sex\nWeight: $::weight ($wchange)\nPace: $::pace\nCalories: $::cals\n\nNotes:\n$::note"
	.wout.t insert end $wtxt
	pack .wout.t -in .wout
}

proc month {} {
	toplevel .month
	wm title .month "Monthly Reports"
	grid [ttk::label .month.lbl -text "Choose month and year: "]\
	[ttk::combobox .month.cmo -width 5 -value [list "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"] -state readonly -textvar ::month]\
	[ttk::combobox .month.cyr -width 5 -value [list "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" "2023" "2024" "2025" "2026" "2027" "2028" "2029" "2030" "2031" "2032" "2033" "2034"] -state readonly -textvar ::year]\
	[ttk::button .month.go -text "get report" -command {moreport}]\
	[ttk::button .month.l -text "view workouts" -command {mowout}]\
	[ttk::button .month.q -text "close" -command {destroy .month}]
}

proc mowout {} {
	toplevel .w
        wm title .w "runlog entries for 2014-01"

	set ymo "$::year-$::month%"
	# bind .w <Escape> {destroy .w}
	text .w.t -wrap word -yscrollcommand ".w.ys set"
        bind .w.t <KeyPress> break
	scrollbar .w.ys -command  ".w.t yview"
        set stuff [db eval {select * from workouts where date like $ymo} {
        .w.t insert end "Date: $date, Distance: $distance, Pace: $pace\nNotes: $notes\n------------\n"
	pack .w.t -in .w -side left -fill both
	pack .w.ys -in .w -side right -fill y
	}]
}


proc moreport {} {
	set ymo "$::year-$::month%"
	sqlite3 db runlog.db
	set totruns [ db eval {select count(*) from workouts where date like $ymo}]
	set totdist [ db eval {select sum(distance) from workouts where date like $ymo}]
	set tothrs [ db eval {select sum(hrs) from workouts where date like $ymo}]
	set totmins [ db eval {select sum(mins) from workouts where date like $ymo}]
	set totsecs [ db eval {select sum(secs) from workouts where date like $ymo}]
	set totcals [ db eval {select sum(cals) from workouts where date like $ymo}]
	
	set mototsecs [expr {($tothrs*3600)+($totmins*60)+$totsecs}]
	set mopacesecs [expr { $mototsecs / $totdist }]
	set mpsx [expr {round($mopacesecs)}]
	set avepace [clock format $mpsx -gmt 1 -format %M:%S]
	set totime [clock format $mototsecs -gmt 1 -format %H:%M:%S]
	set adist [expr {$totdist/$totruns}]
	set avedist [format "%.2f" $adist]
	set mocals [expr {round($totcals)}]


	
	toplevel .moreport 
	bind .moreport <Escape> {destroy .moreport}
	wm title .moreport "Monthly Report $::month/$::year"
	set thismoreport "Monthly Report for $::month/$::year\n\nTotal number of workouts: $totruns\nTotal distance: $totdist\nTotal calories burned: $mocals\nAverage distance: $avedist\nAverage pace: $avepace"
	frame .moreport.t
	text .moreport.t.rpt -width 40 -height 10
	.moreport.t.rpt insert end $thismoreport
	pack .moreport.t.rpt -in .moreport.t
	frame .moreport.b
	grid [ttk::button .moreport.b.s -text "Save" -command {savemonth}]\
       	[ttk::button .moreport.q -text "Okay" -command {destroy .moreport}]
	pack .moreport.t -in .moreport -side top
	pack .moreport.b -in .moreport -side top
}


proc year {} {
	toplevel .year
	wm title .year "Yearly Reports"
	grid [ttk::label .year.lbl -text "Choose year: "]\
	[ttk::combobox .year.cyr -width 5 -value [list "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" "2023" "2024" "2025" "2026" "2027" "2028" "2029" "2030" "2031" "2032" "2033" "2034"] -state readonly -textvar ::year]\
	[ttk::button .year.go -text "get report" -command {yrreport}]\
	[ttk::button .year.q -text "close" -command {destroy .year}]
}

proc yrreport {} {
	set yr "$::year%"
	sqlite3 db runlog.db
	set totruns [ db eval {select count(*) from workouts where date like $yr}]
	set totdist [ db eval {select sum(distance) from workouts where date like $yr}]
	set tothrs [ db eval {select sum(hrs) from workouts where date like $yr}]
	set totmins [ db eval {select sum(mins) from workouts where date like $yr}]
	set totsecs [ db eval {select sum(secs) from workouts where date like $yr}]
	set totcals [ db eval {select sum(cals) from workouts where date like $yr}]
	
	set mototsecs [expr {($tothrs*3600)+($totmins*60)+$totsecs}]
	set mopacesecs [expr { $mototsecs / $totdist }]
	set mpsx [expr {round($mopacesecs)}]
	set avepace [clock format $mpsx -gmt 1 -format %M:%S]
	set totime [clock format $mototsecs -gmt 1 -format %H:%M:%S]
	set adist [expr {$totdist/$totruns}]
	set avedist [format "%.2f" $adist]
	set mocals [expr {round($totcals)}]


	
	toplevel .yreport 
	wm title .yreport "Yearly Report $::year"
	set thisyreport "Yearly Report for $::year\n\nTotal number of workouts: $totruns\nTotal distance: $totdist\nTotal calories burned: $mocals\nAverage distance: $avedist\nAverage pace: $avepace"
	frame .yreport.t
	text .yreport.t.rpt -width 40 -height 10
	.yreport.t.rpt insert end $thisyreport
	pack .yreport.t.rpt -in .yreport.t
	frame .yreport.b
	grid [ttk::button .yreport.b.s -text "Save" -command {savemonth}]\
       	[ttk::button .yreport.q -text "Okay" -command {destroy .yreport}]
	pack .yreport.t -in .yreport -side top
	pack .yreport.b -in .yreport -side top
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
	eval exec "$::browser http://tonyb.us/tclrunlog &"
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

