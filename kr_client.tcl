## krad radio tcl client function library (or s.th. like that)

set sleeptime 100

proc kr {args} {
  global station sleeptime
  puts "kr_client: running krad_radio $station $args"
  exec krad_radio $station {*}$args
  after $sleeptime
}

proc krlaunch {} {
  kr launch
}

proc krkill {} {
  kr destroy
}
