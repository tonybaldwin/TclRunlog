#!/usr/bin/env wish8.5

# runlog.tcl - a runner's workout log
# in tcl/tk by tony baldwin | http://wiki.tonybaldwin.info

package require Tk
package require Ttk
package require sqlite3
package require http
package require tls
package require base64

global uname
global rname
global rpass
global rchan
global rurl
global units
global oweight
global os
global browser
global pace
global cals
global dunit
global pace
global cals
global day
global month
global year
global ymo
global mydate

set year [clock format [clock seconds] -format %Y]
set month [clock format [clock seconds] -format %m]
set day [clock format [clock seconds] -format %d]
set mydate "$::year-$::month-$::day"

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
set rname [ db eval {select value from config where var="rname"}]
set rpass [ db  eval {select value from config where var="rpass"}]
set rurl [ db eval {select value from config where var="rurl"}]
set rchan [ db eval {select value from config where var="rchan"}]

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
	grid [ttk::label .prefs.red -text "RedMatrix Preferences: "]
	grid [ttk::label .prefs.rn -text "Username (e-mail):  "]\
	[ttk::entry .prefs.rname -textvar rname]
	grid [ttk::label .prefs.rp -text "Password: "]\
	[ttk::entry .prefs.rpass  -show * -textvar rpass]
	grid [ttk::label .prefs.ru -text "Site URL: "]\
	[ttk::entry .prefs.rurl -textvar rurl]
	grid [ttk::label .prefs.rc -text "Channel: "]\
	[ttk::entry .prefs.rchan -textvar rchan]
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
	
	db eval {delete from config where var="rname"}
	db eval {insert into config values('rname',$::rname)}
	db eval {delete from config where var="rpass"}
	db eval {insert into config values('rpass',$::rpass)}
	db eval {delete from config where var="rurl"}
	db eval {insert into config values('rurl',$::rurl)}
	db eval {delete from config where var="rchan"}
	db eval {insert into config values('rchan',$::rchan)}

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
	text .wout.t -width 50 -height 15
	set wtxt "$::uname's Running Workout $::date\n\nDistance: $::distance $::dunit\nTime: $::hrs:$::mins:$::sex\nWeight: $::weight ($wchange)\nPace: $::pace mins/$::dunit\nCalories: $::cals\n\nNotes:\n$::note"
	.wout.t insert end $wtxt
	tk::button .wout.rpost -text "Post to Red" -command {
	set update [.wout.t get 1.0 {end -1c}]
	set title "$::uname's Runlog"
	::http::register https 443 ::tls::socket
	set auth "$::rname:$::rpass"
	set auth64 [::base64::encode $auth]
	set myquery [::http::formatQuery "status" "$update" "source" "TclRunlog" "channel" "$::rchan" "title" "$title"]
	set myauth [list "Authorization" "Basic $auth64"]
	set token [::http::geturl $::rurl/api/statuses/update.xml -headers $myauth -query $myquery] 
	}
	pack .wout.t -in .wout
	pack .wout.rpost -in .wout
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
        wm title .w "runlog entries for $::month/$::year"
	destroy .month
	set ymo "$::year-$::month%"
	# bind .w <Escape> {destroy .w}
	text .w.t -width 80 -wrap word -yscrollcommand ".w.ys set"
        bind .w.t <KeyPress> break
	scrollbar .w.ys -command  ".w.t yview"
        set stuff [db eval {select * from workouts where date like $ymo} {
        .w.t insert end "DATE: $date\nDISTANCE: $distance $::dunit, TIME: $hrs:$mins:$secs, CALORIES: $cals, PACE: $pace min/$::dunit\nNOTES:\n$notes\n-------------------------------------------------------------------\n"
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
	set totdist [format "%.2f" $totdist]


	set thismo $::month	
	toplevel .$thismo 
	# bind .$thismo <Escape> {destroy .$thismo}
	wm title .$thismo "Monthly Report $thismo/$::year"
	set thismonth "$::uname's Monthly Run Report for $thismo/$::year\n\nTotal number of workouts: $totruns\nTotal distance: $totdist $::dunit\nTotal calories burned: $mocals\nAverage distance: $avedist $::dunit\nAverage pace: $avepace min/$::dunit\n\n"
	frame .$thismo.t
	text .$thismo.t.rpt -width 40 -height 10
	.$thismo.t.rpt insert end $thismonth
	tk::button .$thismo.rpost -text "Post to Red" -command {
	set thismo $::month	
	set update [.$thismo.t.rpt get 1.0 {end -1c}]
	set title "$::uname's Runlog"
	::http::register https 443 ::tls::socket
	set auth "$::rname:$::rpass"
	set auth64 [::base64::encode $auth]
	set myquery [::http::formatQuery "status" "$update" "source" "TclRunlog" "channel" "$::rchan" "title" "$title"]
	set myauth [list "Authorization" "Basic $auth64"]
	set token [::http::geturl $::rurl/api/statuses/update.xml -headers $myauth -query $myquery] 
	}
	pack .$thismo.t.rpt -in .$thismo.t
	pack .$thismo.t -in .$thismo -side top
	pack .$thismo.rpost -in .$thismo -side bottom
}

proc openwk {} {
	toplevel .opwk1
	wm title .opwk1 "Open Workout"
	grid [ttk::label .opwk1.lbl -text "Choose year/month/day"]\
	[ttk::combobox .opwk1.cyr -width 5 -value [list "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" "2023" "2024" "2025" "2026" "2027" "2028" "2029" "2030" "2031" "2032" "2033" "2034"] -state readonly -textvar ::year]\
	[ttk::combobox .opwk1.cmo -width 5 -value [list "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"] -state readonly -textvar ::month]\
	[ttk::combobox .opwk1.cdy -width 5 -value [list "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31"] -state readonly -textvar ::day]\
	[ttk::button .opwk1.go -text "open" -command {
	destroy .opwk1
	set ::mydate "$::year-$::month-$::day%"
	sqlite3 db runlog.db
	set date [ db eval {select date from workouts where date like $::mydate}]
	set distance [ db eval {select distance from workouts where date like $::mydate}]
	set weight [ db eval {select weight from workouts where date like $::mydate}]
	set hrs [ db eval {select hrs from workouts where date like $::mydate}]
	set mins [ db eval {select mins from workouts where date like $::mydate}]
	set sex [ db eval {select secs from workouts where date like $::mydate}]
	set cals [ db eval {select cals from workouts where date like $::mydate}]
	set pace [ db eval {select pace from workouts where date like $::mydate}]
	set note [ db eval {select notes from workouts where date like $::mydate}]
	destroy .img
	frame .edwk
	frame .edwk.date

	grid [ttk::label .edwk.date.ldate -text "Date: "]\
	[ttk::entry .edwk.date.edate -textvar date]\
	[ttk::button .edwk.date.cdate -text "Current Date" -command {
	set date [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	}]

	frame .edwk.dist
	grid [ttk::label .edwk.dist.ldist -text "Distance: "]\
	[ttk::entry .edwk.dist.edist -width 5 -textvar distance]\
	[ttk::label .edwk.dist.lw -text "Weight: "]\
	[ttk::entry .edwk.dist.ew -width 5 -textvar weight]

	grid [ttk::label .edwk.dist.ltime -text "Time: "]

	frame .edwk.time
	grid [ttk::label .edwk.time.lhrs -text "hours: "]\
	[ttk::entry .edwk.time.ehrs -width 5 -textvar hrs]\
	[ttk::label .edwk.time.lmins -text "minutes: "]\
	[ttk::entry .edwk.time.emins -width 5 -textvar mins]\
	[ttk::label .edwk.time.lsex -text "seconds: "]\
	[ttk::entry .edwk.time.esex -width 5 -textvar sex]

	frame .edwk.calc
	grid [ttk::button .edwk.calc.calc -text "ReCalculate" -command {newcalc}]
	grid [ttk::label .edwk.calc.pc -text "Pace: (min/$::dunit): "]\
	[ttk::entry .edwk.calc.pace -width 5 -textvar pace]
	grid [ttk::label .edwk.calc.clr -text "Calories: "]\
	[ttk::entry .edwk.calc.cals -width 5 -textvar cals]

	grid [ttk::label .edwk.calc.note -text "Notes: "]

	frame .edwk.note
	text .edwk.note.t -width 35 -height 10 -wrap word -yscrollcommand ".edwk.note.ys set"
	scrollbar .edwk.note.ys -command ".edwk.note.t yview"
	.edwk.note.t insert end $note
	pack .edwk.note.t -in .edwk.note -side left -fill both
	pack .edwk.note.ys -in .edwk.note -side left -fill y

	frame .edwk.btns
	grid [ttk::button .edwk.btns.svwk -text "Save" -command {ewout}]\
	[ttk::button .edwk.btns.close -text "Close" -command {
		destroy .edwk
		frame .img
		grid [ttk::label .img.icon -image tclrunlog]
		pack .img -in . -side bottom -fill both
	}]\
	[ttk::button .edwk.btns.clr -text "Clear" -command {
		set wkvars [list distance date weight hrs mins sex pace cals note]	
		foreach var $::wkvars {global $var}
		foreach var $::wkvars {set $var " "}
		.edwk.note.t delete 1.0 end
	}]

	pack .edwk -in . -side bottom
	pack .edwk.date -in .edwk -side top -fill x
	pack .edwk.dist -in .edwk -side top -fill x
	pack .edwk.time -in .edwk -side top -fill x
	pack .edwk.calc -in .edwk -side top -fill x
	pack .edwk.note -in .edwk -side top -fill x
	pack .edwk.btns -in .edwk -side top -fill x
}]\
	[ttk::button .opwk1.q -text "close" -command {destroy .opwk1}]
}


proc ewout {} {
	set ::note [.edwk.note.t get 1.0 {end -1c}]
	sqlite3 db runlog.db
	db eval {delete from workouts where date like $::mydate}
	db eval {replace into workouts values($::date,$::distance,$::hrs,$::mins,$::sex,$::pace,$::weight,$::cals,$::note)}
	set wchange [expr {$::weight - $::oweight}]
	toplevel .wout
	wm title .wout "Workout $::date"
	bind .wout <Escape> {destroy .wout}
	text .wout.t -width 40 -height 10
	set wtxt "$::uname's Workout $::date\n\nDistance: $::distance\nTime: $::hrs:$::mins:$::sex\nWeight: $::weight ($wchange)\nPace: $::pace min/$::dunit\nCalories: $::cals\n\nNotes:\n$::note"
	.wout.t insert end $wtxt
	pack .wout.t -in .wout
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
	set tdist [ db eval {select sum(distance) from workouts where date like $yr}]
	set tothrs [ db eval {select sum(hrs) from workouts where date like $yr}]
	set totmins [ db eval {select sum(mins) from workouts where date like $yr}]
	set totsecs [ db eval {select sum(secs) from workouts where date like $yr}]
	set totcals [ db eval {select sum(cals) from workouts where date like $yr}]
	
	set totdist [format "%.2f" $tdist]
	set mototsecs [expr {($tothrs*3600)+($totmins*60)+$totsecs}]
	set mopacesecs [expr { $mototsecs / $totdist }]
	set mpsx [expr {round($mopacesecs)}]
	set avepace [clock format $mpsx -gmt 1 -format %M:%S]
	set totime [clock format $mototsecs -gmt 1 -format %H:%M:%S]
	set adist [expr {$totdist/$totruns}]
	set avedist [format "%.2f" $adist]
	set mocals [expr {round($totcals)}]


	
	toplevel .$::year 
	wm title .$::year "Yearly Report $::year"
	set thisyear "$::uname's Yearly Run Report for $::year\n\nTotal number of workouts: $totruns\nTotal distance: $totdist $::dunit\nTotal calories burned: $mocals\nAverage distance: $avedist $::dunit\nAverage pace: $avepace min/$::dunit\n"
	frame .$::year.t
	text .$::year.t.rpt -width 40 -height 10
	.$::year.t.rpt insert end $thisyear
	tk::button .$::year.rpost -text "Post to Red" -command {
	set update [.$::year.t.rpt get 1.0 {end -1c}]
	set title "$::uname's Runlog"
	::http::register https 443 ::tls::socket
	set auth "$::rname:$::rpass"
	set auth64 [::base64::encode $auth]
	set myquery [::http::formatQuery "status" "$update" "source" "TclRunlog" "channel" "$::rchan" "title" "$title"]
	set myauth [list "Authorization" "Basic $auth64"]
	set token [::http::geturl $::rurl/api/statuses/update.xml -headers $myauth -query $myquery] 
	}
	pack .$::year.t.rpt -in .$::year.t
	pack .$::year.t -in .$::year -side top
	pack .$::year.rpost -in .$::year -side bottom
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

