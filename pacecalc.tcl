#!/usr/bin/env wish8.5
#
# pace calculator for runners
# by tony baldwin | http://wiki.tonybaldwin.info
# released according to the terms of the 
# Gnu Public License, v. 3 or later.

package require Tk
package require Ttk

global hrs
global mins
global secs
global distance
global dis2
global dis3
global 2mins
global 2secs
global weight
global cals
global pace
global novar
set novar "0"

set allvars [list hrs mins secs distance dis2 dis3 2mins 2secs cals pace weight novar]

bind . <Escape> {exit}


frame .m1 
tk::label .m1.msg -text "Enter distance and total time to calculate pace."

frame .1
grid [ttk::label .1.dist -width 10 -text "Distance: " ]\
[ttk::entry .1.di  -width 10 -textvar distance]\
[ttk::label .1.hr  -text "Hours: "]\
[ttk::entry .1.hour  -width 10 -textvar hrs]\
[ttk::label .1.mins -text "Minutes: "]\
[ttk::entry .1.mnts  -width 10 -textvar mins]\
[ttk::label .1.sex -text "Seconds: "]\
[ttk::entry .1.secs  -width 10 -textvar secs]\
[ttk::button .1.calc -text "Calculate" -command {calc1}]

pack .m1 -in . -side top -fill x
pack .m1.msg -in .m1 -side left -fill x
pack .1 -in . -side top -fill x

frame .m2
tk::label .m2.msg -text "Enter distance and pace in minutes and seconds per mile to calculate total time."

frame .2
grid [ttk::label .2.dist -text "Distance: "]\
[ttk::entry .2.dstn  -width 10 -textvar dis2]\
[ttk::label .2.p -text "MM:SS/mile : "]\
[ttk::entry .2.m  -width 10 -textvar 2mins]\
[ttk::label .2.sep -text ":"]\
[ttk::entry .2.s  -width 10 -textvar 2secs]\
[ttk::button .2.calc -text "Calculate" -command {calc2}]

pack .m2 -in . -side top -fill x
pack .m2.msg -in .m2 -side left -fill x
pack .2 -in . -side top -fill x

frame .m3
tk::label .m3.msg -text "Calculate calories burned."

frame .3
grid [ttk::label .3.dist -text "Distance: "]\
[ttk::entry .3.dstn  -width 10 -textvar dis3]\
[ttk::label .3.p -text "Weight"]\
[ttk::entry .3.m  -width 10 -textvar weight]\
[ttk::button .3.b -text "Calculate" -command {calcal}]\
[ttk::button .3.c -text "Clear all" -command {clear}]\
[ttk::button .3.q -text "Quit" -command {exit}]

pack .m3 -in . -side top -fill x
pack .m3.msg -in .m3 -side left -fill x
pack .3 -in . -side top -fill x


proc calc1 {} {

	if { $::secs != "00" } {
	set seconds [ string trimleft $::secs 0 ]
	} else { set seconds $::secs }
	if { $::hrs != "00" } {
	set hours [ string trimleft $::hrs 0 ]
	} else { set hours $::hrs }
	if { $::mins != "00" } {
	set minutes [ string trimleft $::mins 0 ]
	} else { set minutes $::mins }
	set tsex [expr { ($hours*3600)+($minutes*60)+$seconds }]
	set pacesecs [expr { $tsex / $::distance }]
	set pacesex [expr {round($pacesecs)}]
	set pace [clock format $pacesex -gmt 1 -format %M:%S]
	
	toplevel .calc
	grid [ttk::label .calc.pace -text "Pace: $pace min/mi."]\
	[ttk::button .calc.ok -text "ok" -command {destroy .calc}]

}

proc calc2 {} {
	if { $::2mins != "00" } {
		set ::2mins [ string trimleft $::2mins 0] 
	}
	if { $::2secs != "00" } {
		set ::2secs [string trimleft $::2secs 0]
	}
	set sexpmi [expr {($::2mins * 60) + $::2secs}]
	set totsex [expr { $sexpmi * $::dis2 }]
	set totime [clock format $totsex -gmt 1 -format %H:%M:%S]

	toplevel .calc2
	grid [ttk::label .calc2.l -text "Total time: $totime"]\
	[ttk::button .calc2.b -text "ok" -command {destroy .calc2}]

}

proc calcal {} {
	set cals [expr {0.7568 * $::weight * $::dis3}]

	toplevel .ccalc
	grid [ttk::label .ccalc.cal -text "Calories burned (approx.): $cals"]\
	[ttk::button .ccalc.b -text "ok" -command {destroy .ccalc}]
}

proc clear {} {
	foreach var $::allvars {global $var}
	foreach var $::allvars {set $var " "}
}
