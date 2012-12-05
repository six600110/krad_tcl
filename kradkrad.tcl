## TODO: use kr_client.tcl everywhere :D

#source kr_client.tcl
#
#set sleeptime 100
#set station logger

proc init {} {
  global texts

  ## delete all possibly exising texts
  for {set i 0} {$i <= 18} {incr i} {
    exec "krad_radio" "logger" "rmtext" "$i"
    after 100
  }

  ## Now add 9 empty texts so we get the IDs correct
  for {set i 1} {$i <= 18} {incr i} {
    exec "krad_radio" "logger" "addtext" "PLACEHOLDER $i (chat to get me away)" "10" [expr (10 + $i * 20) - 20] "4" "10.0f" "1.0f" "0.0f" [lindex $texts([expr $i - 1]) 1] [lindex $texts([expr $i - 1]) 2] [lindex $texts([expr $i - 1]) 3]
    after 100
  }
}

proc pub_krad_cocorot {nick uhost hand chan rest} {
  putlog "IS DOUBLE: [string is double [lindex $rest 0]]"
  if {[string is double [lindex $rest 0]]} {
    exec "krad_radio" "logger" "setsprite" "1" "540" "260" "4" "1.0f" "1.0f" [lindex $rest 0]
  }
}

proc randomcolor {} {
  set r 0; set g 0; set b 0;
  while {(!($r >= 200 || $g >= 200 || $b >= 200)) || ([expr $r + $b + $g] >= 400)} {
    set r [expr round(rand() * 255)]
    set g [expr round(rand() * 255)]
    set b [expr round(rand() * 255)]
  }
  return "$r $g $b"
}

proc addtext {type nick msg} {
  global texts
  ## Delete the topmost text
  set idtouse [lindex $texts(0) 0]
  exec "krad_radio" "logger" "rmtext" $idtouse

  ## Move all other texts (pos 1 -> 8) up, updating the array as we go
  for {set i 1} {$i <= 17} {incr i} {
    set texts([expr $i - 1]) $texts($i)
    exec "krad_radio" "logger" "settext" [lindex $texts($i) 0] 10 [expr (10 + $i * 20) - 20] "4" "10.0f" "1.0f" "0.0f"  [lindex $texts($i) 1] [lindex $texts($i) 2] [lindex $texts($i) 3]
    after 100
  }

  ## Add new line re-using the previously deleted ID
  set texts(17) "$idtouse [randomcolor]"
  set msg [string range "${nick}: $msg" 0 120]
  exec "krad_radio" "logger" "addtext" "$msg" "10" "350" "4" "10.0f" "1.0f" "0.0f"  [lindex $texts(17) 1] [lindex $texts(17) 2] [lindex $texts(17) 3]
  after 100
}

proc pub_krad_msg {nick uhost hand chan rest} {
  addtext msg $nick $rest
}

#proc pub_join {nick uhost handle chan} {
#  add2db join $nick ""
#}
#
#proc pub_part {nick uhost handle chan msg} {
#  add2db part $nick $msg
#}
#
#proc pub_sign {nick uhost handle chan msg} {
#  add2db part $nick $msg
#}
#
#proc pub_kick {nick uhost handle chan target msg} {
#  add2db kick $nick "$target ($msg)"
#}
#
#proc pub_nick {nick uhost handle chan newnick} {
#  add2db nick $nick $newnick
#}

## Initial array:
## POS (0=top, 8=bot): KR-ID, RED, GREEN, BLUE)
array set texts {}
for {set i 0} {$i <= 17} {incr i} {
  set texts($i) "$i [randomcolor]"
}
putlog "Initial array: [array get texts]"

init

putlog "Loaded: Script: kradkrad"
