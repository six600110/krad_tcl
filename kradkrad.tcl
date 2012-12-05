source kr_client.tcl

set sleeptime 100
set station logger

set sourcehost kripserver.net
set sourceport 12000
set sourcepass pass

proc init {} {
  global texts sourcehost sourceport sourcepass

  krkill
  krlaunch

  kr setdir ~/testlogs/
  kr setres 640 360
  kr res 640 360
  kr addsrpite /home/eggdrop/sprite.png
  kr addsprite /home/eggdrop/coco-sprite.png 540 260
  kr transmit video $sourcehost $sourceport /logger.webm $sourcepass vp8 640 360 50

  ## delete all possibly exising texts
  for {set i 0} {$i <= 18} {incr i} {
    kr "rmtext" "$i"
  }

  ## Now add 9 empty texts so we get the IDs correct
  for {set i 1} {$i <= 18} {incr i} {
    kr "addtext" "PLACEHOLDER $i (chat to get me away)" "10" [expr (10 + $i * 20) - 20] "4" "10.0f" "1.0f" "0.0f" [lindex $texts([expr $i - 1]) 1] [lindex $texts([expr $i - 1]) 2] [lindex $texts([expr $i - 1]) 3]
  }
}

proc pub_krad_cocorot {nick uhost hand chan rest} {
  if {[string is double [lindex $rest 0]]} {
    kr "setsprite" "1" "540" "260" "4" "1.0f" "1.0f" [lindex $rest 0]
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
  kr "rmtext" $idtouse

  ## Move all other texts (pos 1 -> 8) up, updating the array as we go
  for {set i 1} {$i <= 17} {incr i} {
    set texts([expr $i - 1]) $texts($i)
    kr "settext" [lindex $texts($i) 0] 10 [expr (10 + $i * 20) - 20] "4" "10.0f" "1.0f" "0.0f"  [lindex $texts($i) 1] [lindex $texts($i) 2] [lindex $texts($i) 3]
  }

  ## Add new line re-using the previously deleted ID
  set texts(17) "$idtouse [randomcolor]"
  set msg [string range "${nick}: $msg" 0 120]
  kr "addtext" "$msg" "10" "350" "4" "10.0f" "1.0f" "0.0f"  [lindex $texts(17) 1] [lindex $texts(17) 2] [lindex $texts(17) 3]
}

proc pub_krad_msg {nick uhost hand chan rest} {
  addtext msg $nick $rest
}

## Initial array:
## POS (0=top, 8=bot): KR-ID, RED, GREEN, BLUE)
array set texts {}
for {set i 0} {$i <= 17} {incr i} {
  set texts($i) "$i [randomcolor]"
}

init

putlog "Loaded: Script: kradkrad"
