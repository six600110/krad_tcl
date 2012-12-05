#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

source kr_client.tcl

set icecast_host 127.0.0.1
set icecast_port 12000
set icecast_pass "pass"

set kr_width 320
set kr_height 240
set kr_codec "vp8vorbis"
set kr_bitrate 10

if {[llength $argv]} {
  set station [lindex $argv 0]
} else {
  set station v[expr round(rand() * 10)][expr round(rand() * 10)][expr round(rand() * 10)]
}

puts "Setting up virtual feed $station"

krlaunch
kr setdir "/home/kripton/testlogs/"
kr res $kr_width $kr_height
kr transmit audiovideo $icecast_host $icecast_port /$station $icecast_pass $kr_codec $kr_width $kr_height $kr_bitrate
kr capture test
kr addtext $station [expr $kr_width * 0.15] [expr $kr_height * 0.6]  4 100.0f 1.0f 0.0f 255 255 255

# reduce CPU usage
kr update vp8_min_quantizer 33

puts "All set up :D"
