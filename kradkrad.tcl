source scripts/kr_client.tcl

set sleeptime 100
set station logger

set sourcehost europa.kradradio.com
set sourceport 8008
set sourcepass krad

proc init {} {
  global texts sourcehost sourceport sourcepass

  krkill
  krlaunch

  kr "setdir" "~/krad_stations"

  kr "res" "640" "360"

  kr "input" "in"
  kr "output" "out"
  kr "display"
  kr "background" "/home/six600110/Pictures/unicorn_rainbow_ass_trail.jpg"
  kr "addsprite" "/home/six600110/Pictures/oneman.png"
  kr "sprite/0/xscale" "0.2" "100"
  kr "sprite/0/yscale" "0.2" "100"
  kr "sprite/0/x" "550" "100"
  kr "sprite/0/y" "260" "100"

  kr transmit av $sourcehost $sourceport /logger.webm 

  ## delete all possibly exising texts
  for {set i 0} {$i <= 18} {incr i} {
      kr "rm" "text/$i" 
  }

  ## Now add 9 empty texts so we get the IDs correct
  for {set i 1} {$i <= 18} {incr i} {
    kr "addtext" "PLACEHOLDER $i (chat to get me away)" 

      #"10.0f" "1.0f" "0.0f" 

     kr [format "text/%d/xscale" [expr ($i-1)] ]   "10" "100"
      kr [format "text/%d/x" [expr ($i-1)] ]  "10" "100"
      kr [format "text/%d/y" [expr ($i-1)] ]   [expr (10 + $i * 20) - 20] "100"
      kr [format "text/%d/red" [expr ($i-1)] ]  [lindex $texts([expr $i - 1]) 1]
      kr [format "text/%d/green" [expr ($i-1)] ]  [lindex $texts([expr $i - 1]) 2] 
      kr [format "text/%d/blue" [expr ($i-1)] ]  [lindex $texts([expr $i - 1]) 3] 

  }

}

proc pub_krad_cocorot {nick uhost hand chan rest} {
  if {[string is double [lindex $rest 0]]} {
    kr "sprite/0/r" [lindex $rest 0] "100"
  }
}

proc randomcolor {} {
  set r 0; set g 0; set b 0;
  while {(!($r >= 0.78 || $g >= 0.78 || $b >= 0.78)) || ([expr $r + $b + $g] >= 1.56)} {
      set r [expr rand()]
    set g [expr rand()]
    set b [expr rand()]
  }
  return "$r $g $b"
}

proc addtext {type nick msg} {
  global texts
  ## Delete the topmost text
  set idtouse [lindex $texts(0) 0]
    kr "rm" [format "text/%d" $idtouse]

  ## Move all other texts (pos 1 -> 8) up, updating the array as we go
  for {set i 1} {$i <= 17} {incr i} {
    set texts([expr $i - 1]) $texts($i)
      kr [format "text/%d/x" [lindex $texts($i) 0]] "10" "100" 
      kr [format "text/%d/y" [lindex $texts($i) 0]] [expr (10 + $i * 20) - 20] "100"


  }

  ## Add new line re-using the previously deleted ID
  set texts(17) "$idtouse [randomcolor]"
  set msg [string range "${nick}: $msg" 0 120]
  kr "addtext" "$msg" 
  kr [format "text/%d/red" [lindex $texts(17) 0]]   [lindex $texts(17) 1] 
  kr [format "text/%d/green" [lindex $texts(17) 0]]  [lindex $texts(17) 2] 
    kr [format "text/%d/blue" [lindex $texts(17) 0]]  [lindex $texts(17) 3] 
  kr [format "text/%d/x" [lindex $texts(17) 0]] "10" "100"
  kr [format "text/%d/y" [lindex $texts(17) 0]] "350" "100"
  kr [format "text/%d/xscale"  [lindex $texts(17) 0]] "10" "100"
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

#putlog "Loaded: Script: kradkrad"
