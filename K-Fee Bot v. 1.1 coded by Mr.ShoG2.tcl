################################################################################
# K-Fee Bot v. 1.1 coded by Mr.ShoG                                                          #
# Mr.ShoG (C) 2006                                                                        #
################################################################################
#                                                                                                                                           #
# Edit the variables below to match your mysql configuration                      #
#                                                                                                                                        #
################################################################################

set mysql_(user) "*****"
set mysql_(password) "******"
set mysql_(host) "localhost"
set mysql_(db) "pre"
set mysql_(table) "pred"
set mysql_(craptable) "craptable"

set db_(rlsname) "name"
set db_(section) "type"
set db_(status) "status"
set db_(reason) "reason"
set db_(id) "id"
set db_(time) "time"
set db_(files) "files"
set db_(size) "size"
set db_(nick) "nick"
set db_(genre) "genre"


################################################################################
#                                                                                                                                           #
# Edit the variables below to match some other configuration                      #
#                                                                                                                                        #
################################################################################

# Channel Settings

set addprechan "#addpre"
set staffchan "#pre.staff"
set prechan "#pre"
set spamchan "#pre.spam"
set mainchan "#FN"
set searchchan "#search"

# Prefixes for announce
set prefix_(site) "\0036\002\[\003\00314PRE\003\0036\]\002\003 -"
set prefix_(nuke) "^C7\[^C^C4NUKE^C^C7\]^C"
set prefix_(unnuke) "^C7\[^C^C3UNNUKE^C^C7\]^C"

# Flags for Channel Announce

setudef flag search
setudef flag listen
setudef flag db
setudef flag add
setudef flag spam
setudef flag stats

# Triggers for Channels with DB Flag

bind pub -|- !cmd ms:cmdlist
bind pub -|- !prechan ms:invite


# Triggers for Channel with SEARCH Flag

bind pub -|- !dupe ms:dupe
bind pub -|- !pre ms:pre


# Triggers for Channel with ADD and/or DB Flag

bind pub -|- !addpre ms:addpre
bind pub -|- !nuke ms:nuke
bind pub -|- !n ms:nuke
bind pub -|- !unnuke ms:unnuke
bind pub -|- !u ms:unnuke
bind pub -|- !info ms:info
bind pub -|- !addinfo ms:info
bind pub -|- !genre ms:genre
bind pub -|- !addgenre ms:genre
bind pub -|- !gn ms:genre
bind pub -|- !delpre ms:delpre

################################################################################
#                                                                                                #
# DON'T CHANGE ANYTHING BELOW HERE UNLESS YOU KNOW WHAT U ARE DOING              #
#                                                                                                #
################################################################################

set data ""
set data [open "/home/rikt/eggdrop/scripts/spamfilter.txt" r+]
set crapwords [read $data]
set crapwords [split $crapwords " "]
 putlog "Crapwords successfully loaded!!"


set spamvar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set spamturn "0"

set nukevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set nuketurn "0"

set unnukevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set unnuketurn "0"

set infovar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set infoturn "0"

set genrevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set genreturn "0"

set botmaster "RikT"

proc ms:cmdlist { nick uhost hand chan arg } {
global searchchan addprechan
    set chan [string tolower $chan]
    if {$chan == $addprechan} {
      putserv "PRIVMSG $chan : \002Commands Available\002"
      putserv "PRIVMSG $chan : !addpre <release> <section>"
      putserv "PRIVMSG $chan : !info <release> <files> <size>"
      putserv "PRIVMSG $chan : !gn <release> <genre>"
      putserv "PRIVMSG $chan : !nuke <release> <reason>"
      putserv "PRIVMSG $chan : !unnuke <release> <reason>"
      putserv "PRIVMSG $chan : !delpre <release> \002(\002\0034\002Use this for pre.spam\002\003\002)\002"
 
  }
  if {$chan == $searchchan} {
      putserv "PRIVMSG $chan : \002Commands Available\002"
	  putserv "PRIVMSG $chan : !pre <name>"
	  putserv "PRIVMSG $chan : !nuke <name"
	  putserv "PRIVMSG $chan : !db will show the db info"
	  }
}

proc highlight_string {strin subject pre past} {
    return [regsub -all -- $strin $subject "$pre\\0$past"] }
   

proc ms:dupe {nick uhost hand chan arg} { 
      global mysql_ db_ searchchan

  if {$chan == $searchchan} {
        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
        set query1 [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%$sea1%' ORDER BY $db_(time) DESC LIMIT 10" -flatlist];
          if {$query1 == ""} {
              putquick "PRIVMSG $chan : nothing found for $arg"
          } elseif {$query1 != ""} {
              putquick "PRIVMSG $chan : Sending $nick Search Result"
              putquick "PRIVMSG $nick : Your Top 10 results for \"\002$sea1\002\""
          foreach {rls type files mb status reason timestamp} $query1 { 
          set rls [highlight_string $sea1 $rls \002 \002]
          set time1 [unixtime]
          incr time1 -$timestamp
          set ago [duration $time1] 
                if { $status == "1"} {
                  putquick "PRIVMSG $nick : [clock format $timestamp -format "%d-%m-%Y %H:%M:%S"] $rls NUKED: $reason"
                } elseif { $status == "0" } {
                  putquick "PRIVMSG $nick : [clock format $timestamp -format "%d-%m-%Y %H:%M:%S"] $rls "
                } else {
                  putquick "PRIVMSG $chan : Error in der Suche" }
                  }
  } else {
      putlog "ERROR in (DUPECHECK)"
  }
  mysqlclose $mysql_(handle)
}
}

proc ms:pre {nick uhost hand chan arg} {
      global mysql_ db_

        set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -pass $mysql_(password) -db $mysql_(db)];

global searchchan
  set chan [string tolower $chan]
  if {$chan == $searchchan} {
        set before [clock clicks -milliseconds]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
        set query1 [mysqlsel $handle "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%$sea1%' ORDER BY $db_(time) DESC LIMIT 5 " -flatlist];
            if {$query1 == ""} {
                putquick "PRIVMSG $chan : Nothing found for \037 $arg \037"
            } else {
              foreach {rls type files mb nuke reason timestamp} $query1 {
              set sea1 [string map [list "*" "%" " " "%"] $arg];
              set sea2 [string map [list "%" "*"] $sea1];
              set query1 [mysqlsel $handle "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%$sea1%' ORDER BY $db_(time) DESC LIMIT 5 " -flatlist];
            if {$query1 == ""} {
                putquick "PRIVMSG $chan : Nothing found for \037 $arg \037"
            } else {
            foreach {rls type files mb nuke reason timestamp} $query1 {
            set time1 [unixtime]
            incr time1 -$timestamp
            set ago [duration $time1]
            set after [clock clicks -milliseconds]
              if {$nuke == "0"} {
              set f "FiLES"
              set m "MB"
                  putquick "PRIVMSG $chan :\[PREd\] ( $type ) -- $rls  ( [clock format $timestamp -format %d.%m.%Y] ) ( [clock format $timestamp -format %H:%M:%S] ) with ( $files$f ) ( $mb$m ) pred $ago ago"
              } elseif {$nuke == "1"} {
              set f "FiLES"
              set m "MB"
                  putquick "PRIVMSG $chan :\[\0034NUKE\003\] ( \0033$type\003 ) -- $rls  \002(\002 \037\0034$reason\037\003 \002)\002 was pred \0030::\003 \002( [clock format $timestamp -format %d.%m.%Y] )\002 \002( [clock format $timestamp -format %H:%M:%S] )\002 with \002( $files$f ) ( $mb$m )\002 -- pred $ago ago"
              } else {
        putlog "ERROR in (PRESEARCH)"
    }
  }
}
  set ms "MS"
  set duration 0
  set duration [expr $after - $before]
  set duration "$duration.00000"
  set duration1 [expr $duration / 60]
      }
    }
  } else {
	putquick "NOTICE $nick :please join $searchchan for searches ty"
}
  mysqlclose $handle

}
proc ms:addpre { nick uhost hand chan arg } {	
global addprechan 
if {$chan == $addprechan } {
          global prefix_ mysql_ db_ crap_ spamvar spamturn staffchan spamchan prechan
		      set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
              set splitz [split $arg " "]
              set add_(release) [lrange $splitz 0 0]
              set add_(release) [string trimleft $add_(release) "\\\{"]
              set add_(release) [string trimright $add_(release) "\\\}"]
              set add_(section) [lrange $splitz 1 1]
              set add_(section) [string trimleft $add_(section) "\\\{"]
              set add_(section) [string trimright $add_(section) "\\\}"]
              set add_(nick) $nick
              set add_(time) [clock seconds]
              set temp1 [split $add_(release) -]
              set group [lindex $temp1 end]
              set rlsl [string length $add_(release)]
			  set add_(time) [clock seconds]
                                                            
        set numrel [mysqlsel $mysql_(handle) "SELECT * FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'"]                         
            if { $numrel == 0 } {
			        set numrel10 [mysqlsel $mysql_(handle) "SELECT * FROM pre_name WHERE Section = '$add_(section)'"]                         
					            if { $numrel10 != 0 } {

			                      set q [mysqlsel $mysql_(handle) "SELECT * FROM pre_name WHERE Section = '$add_(section)'" ]                
 								   mysqlmap $mysql_(handle) { ID new_Section mIRC } {
								   set mircode "$mIRC"
								   }
								   } else {
								   set mircode "3$add_(section)"
								   }
               
                set nix [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(time),$db_(nick)) VALUES ( '$mircode' , '$add_(release)' , '$add_(time)' , '$nick' )"]
				
                      set q [mysqlsel $mysql_(handle) "SELECT * FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'" ]                
 								   mysqlmap $mysql_(handle) { name section } {

                            
                                putquick "PRIVMSG $prechan : $prefix_(site) \0036\002\[\002\003$name\0036\002\]\003 - \0036\[\002\003$section\0036\002\]\002\003"
							}
						}
					mysqlclose $mysql_(handle)

			}

	}                                                                                     
				


proc ms:nuke { nick uhost hand chan arg } {
	global addprechan spamchan prechan mysql_ db_ prefix_ nukevar nuketurn

	if {$chan == $addprechan } {
	                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

          if {[lsearch $nukevar [lindex $arg 0]] == "-1"} {
          set nukevar [lreplace $nukevar $nuketurn $nuketurn [lindex $arg 0]]
          incr nuketurn
          if {$nuketurn >= 29} {set nuketurn 0}
      set splitz [split $arg " "]
      set nuke_(release) [lrange $splitz 0 0]
      set nuke_(release) [string trimright $nuke_(release) "\\\{"]
      set nuke_(release) [string trimleft $nuke_(release) "\\\}"]
      set nuke_(reason) [lrange $splitz 1 1]
      set nuke_(reason) [string trimleft $nuke_(reason) "\\\{"]
      set nuke_(reason) [string trimright $nuke_(reason) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$nuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $nuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                        if { $numrel != 0 && $rskip != 1 } {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=1, $db_(reason)='$nuke_(reason)' WHERE $db_(rlsname)='$nuke_(release)'"
							set q [mysqlsel $mysql_(handle) "SELECT name,type,reason FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason } {
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putquick "PRIVMSG $prechan : \0036\002\[\002\0034NUKE\0036\002\] \[\002\003$name\0036\002\]  \[\002\003$reason\0036\]\002\003" }

                          }
              }
    }
	                             mysqlclose $mysql_(handle)

  }
}
      

proc ms:unnuke { nick uhost hand chan arg } {
	global addprechan spamchan prechan mysql_ db_ prefix_ unnukevar unnuketurn
    if {$chan == $addprechan} {
	   set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !unnuke <release> <reason>"
        } else {
          if {[lsearch $unnukevar [lindex $arg 0]] == "-1"} {
          set unnukevar [lreplace $unnukevar $unnuketurn $unnuketurn [lindex $arg 0]]
          incr unnuketurn
          if {$unnuketurn >= 29} {set unnuketurn 0}
      set splitz [split $arg " "]
      set unnuke_(release) [lrange $splitz 0 0]
      set unnuke_(release) [string trimright $unnuke_(release) "\\\{"]
      set unnuke_(release) [string trimleft $unnuke_(release) "\\\}"]
      set unnuke_(reason) [lrange $splitz 1 1]
      set unnuke_(reason) [string trimleft $unnuke_(reason) "\\\{"]
      set unnuke_(reason) [string trimright $unnuke_(reason) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$unnuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$unnuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $unnuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                        if { $numrel != 0 } {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=0, $db_(reason)='$unnuke_(reason)' WHERE $db_(rlsname)='$unnuke_(release)'"
                            set q [mysqlsel $mysql_(handle) "SELECT name,type,reason FROM $mysql_(table) WHERE $db_(rlsname) = '$unnuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason } {
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putquick "PRIVMSG $prechan : \0036\002\[\003\0023UNNUKE\0036\002\] \[\002\003$name\0036\002\]  \[\002\003$reason\0036\002\]\003\002" }
                      }
            }
  }
}
}
                    mysqlclose $mysql_(handle)
					}
bind time -|- "00 * * * *" ms:hour
bind pub -|- !hour ms:hour2

proc ms:hour { min hour day month year } {
        global mysql_ db_ searchchan prechan
		set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set now [clock seconds]
        set dur [expr $now - 3600]
        set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(time) > $dur"
        set numrel [mysqlsel $mysql_(handle) $q]
        set w "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(status)=1 AND $db_(time) > $dur"
        set nukerel [mysqlsel $mysql_(handle) $w]
			putquick "PRIVMSG $prechan : 14(2Last Hour pre stats14) 7(4PREs: $numrel7) 7(4Nukes:$nukerel7)"

			putquick "PRIVMSG $searchchan : 14(2Last Hour pre stats14) 7(4PREs: $numrel7) 7(4Nukes:$nukerel7)"
			putquick "TOPIC $searchchan : 14\[2Last Hour pre stats14\] 7\[4PREs: $numrel7\] 7\[4Nukes:$nukerel7\] !prehelp to get pre commands"
                                  mysqlclose $mysql_(handle)

  }
proc ms:hour2 { min hour day month year } {
        global mysql_ db_ searchchan 
		set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set now [clock seconds]
        set dur [expr $now - 3600]
        set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(time) > $dur"
        set numrel [mysqlsel $mysql_(handle) $q]
        set w "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(status)=1 AND $db_(time) > $dur"
        set nukerel [mysqlsel $mysql_(handle) $w]

			putquick "PRIVMSG $searchchan : 14(2Last Hour pre stats14) 7(4PREs: $numrel7) 7(4Nukes:$nukerel7)"
                                  mysqlclose $mysql_(handle)

  }  
proc ms:info { nick uhost hand chan arg } {
	global mysql_ db_ addprechan spamchan prechan infovar infoturn
    if {$chan == $addprechan} {
	                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !addinfo <release> <files> <size>"
        } else {
          if {[lsearch $infovar [lindex $arg 0]] == "-1"} {
          set infovar [lreplace $infovar $infoturn $infoturn [lindex $arg 0]]
          incr infoturn
          if {$infoturn >= 29} {set infoturn 0}
          set splitz [split $arg " "]
          set info_(release) [lrange $splitz 0 0]
          set info_(release) [string trimleft $info_(release) "\\\{"]
          set info_(release) [string trimright $info_(release) "\\\}"]
          set info_(files) [lrange $splitz 1 1]
          set info_(files) [string trimleft $info_(files) "\\\{"]
          set info_(files) [string trimright $info_(files) "\\\}"]
          set info_(size) [lrange $splitz 2 2]
          set info_(size) [string trimleft $info_(size) "\\\{"]
          set info_(size) [string trimright $info_(size) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$info_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(files)='$info_(files)' , $db_(size)='$info_(size)' WHERE $db_(rlsname)='$info_(release)'"]
							putquick "PRIVMSG $prechan 7\[Info7\]-7\[$info_(release)7\]-7\[$info_(files)12Files $info_(size)4MB7\]"
          }
    }
}
}
                                mysqlclose $mysql_(handle)
}                  
proc ms:delpre { nick uhost hand chan arg } {
            global mysql_ prefix_ db_ addprechan spamchan prechan

    if {$chan == $addprechan} {
	            set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

      if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !delpre <release> <reason> " }
      if { $arg != "" } {
          set splitz [split $arg " "]
          set del_(release) [lrange $arg 0 0]
          set del_(release) [string trimleft $del_(release) "\\\{"]
          set del_(release) [string trimright $del_(release) "\\\}"]
          set del_(reason) [lrange $arg 1 1]
          set del_(reason) [string trimleft $del_(reason) "\\\{"]
          set del_(reason) [string trimright $del_(reason) "\\\}"]
		            set del_(by) [lrange $arg 2 2]
          set del_(by) [string trimleft $del_(by) "\\\{"]
          set del_(by) [string trimright $del_(by) "\\\}"]
            set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
            set numrel [mysqlsel $handle $q]
                if { $numrel != 0 } {
                    mysqlsel $handle "SELECT $db_(section),$db_(nick),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
                    mysqlmap $handle { dbsection dbnick dbtime } {
                    set q "DELETE FROM $mysql_(table) WHERE $db_(rlsname)='$del_(release)'"
                    set nix [mysqlexec $handle $q]
						#putlog "deleted $del_(release) from database"
                       putquick "PRIVMSG $prechan 7\[12DELPRE7\]-7\[3$del_(release)7\]-7\[Reason:$del_(reason)\7]-7\[BY: $del_(by)7\]"
            }
      } 
  }
}       
                    mysqlclose $handle
}
proc ms:genre { nick uhost hand chan arg } {
	global mysql_ db_ genrevar genreturn spamchan addprechan
    if {$chan == $addprechan} {
	                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

	if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !addgenre <release> <genre>"
        } else {
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(genre) [lrange $splitz 1 1]
          set fee_(genre) [string trimleft $fee_(genre) "\\\{"]
          set fee_(genre) [string trimright $fee_(genre) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                            putquick "PRIVMSG $chan : \002$fee_(release)\002 not found in my DB"
                          } else {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$fee_(genre)' WHERE $db_(rlsname)='$fee_(release)'"
                        }
                }
          if {[lsearch $genrevar [lindex $arg 0]] == "-1"} {
          set genrevar [lreplace $genrevar $genreturn $genreturn [lindex $arg 0]]
          incr genreturn
          if {$genreturn >= 29} {set genreturn 0}
          set splitz [split $arg " "]
          set genre_(release) [lrange $splitz 0 0]
          set genre_(release) [string trimleft $genre_(release) "\\\{"]
          set genre_(release) [string trimright $genre_(release) "\\\}"]
          set genre_(genre) [lrange $splitz 1 1]
          set genre_(genre) [string trimleft $genre_(genre) "\\\{"]
          set genre_(genre) [string trimright $genre_(genre) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$genre_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$genre_(genre)' WHERE $db_(rlsname)='$genre_(release)'"]
							putquick "PRIVMSG $spamchan 7\[Genre7\]-7\[$genre_(release)7\]-7\[$genre_(genre)7\]"
          }
    }

}
                                mysqlclose $mysql_(handle)
	}                     
  
               

bind pub -|- !groupnukes ms:groupnukes

proc ms:groupnukes {nick uhost hand chan arg } {
    set chan [string tolower $chan]
	global searchchan mysql_ db_

    if {$chan == $searchchan} {
              set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	
	if { $arg == "" } {
          putquick "PRIVMSG $chan : No group set!"
        } else {
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set group [string trimright $group "\\\}"]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$group'"]
              if { $numrel == 0 } {
                putquick "PRIVMSG $chan : No Release found for $arg"
              } else {
              putquick "PRIVMSG $chan : pm'ing $nick with the results"
              putquick "PRIVMSG $nick : \[\002\0032\$arg\002\0032\] $arg has $numrel Nuked Releases in my DB"
              putquick "PRIVMSG $nick : \[\002\0032\$arg\002\0032\] Showing last 5 Nuked Releases:"
              set q [mysqlsel $mysql_(handle) "SELECT name,type,status,reason FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$arg' AND $db_(status)=1 ORDER BY $db_(time) DESC LIMIT 0,5"]
              mysqlmap $mysql_(handle) { name section status reason } {
                  putquick "PRIVMSG $nick : \[\002\0032\$group\002\0032\] (\0033 $section \003) - $name -> (\037\0033$reason\037\003)"
                  }
      }
  }
  mysqlclose $mysql_(handle)

}
}

bind pub -|- !group ms:group

proc ms:group {nick uhost hand chan arg } {
    set chan [string tolower $chan]
	global searchchan mysql_ db_

    if {$chan == $searchchan} {
              set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	
	if { $arg == "" } {
          putquick "PRIVMSG $chan : No group set!"
        } else {
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set group [string trimright $group "\\\}"]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$group'"]
              if { $numrel == 0 } {
                putquick "PRIVMSG $chan : No Release found for $arg"
              } else {
			      putquick "PRIVMSG $chan : pm'ing $nick with the results"
              putquick "PRIVMSG $nick : \[$arg\] $arg has $numrel Releases in my DB"
              putquick "PRIVMSG $nick : \[$arg\] Showing last 5 Releases:"
              set q [mysqlsel $mysql_(handle) "SELECT name,type FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$arg' ORDER BY $db_(time) DESC LIMIT 5"]
              mysqlmap $mysql_(handle) { name section } {
                  putquick "PRIVMSG $nick : \[$group\] (\0033 $section \003) - $name"
                  }
      }
  }
  mysqlclose $mysql_(handle)

}
}

bind pub -|- !db ms:db

proc ms:db {nick uhost hand chan arg} {
    global mysql_ db_
      set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)];
      set row [lindex [mysqlsel $handle "SHOW TABLE STATUS LIKE '$mysql_(table)';" -list] 0]
        set q "SELECT COUNT(id) as anzahl from $mysql_(table)"
      set numrel [mysqlsel $handle $q]
            mysqlmap $handle { anzahl } {
                  putquick "PRIVMSG $chan : \[DB\] -\0033 $anzahl\003 Releases in my DB! Using\002\0033 [format %.2f [expr [lindex $row 5] / 1024.0]] \003\002 KB."
    
}
}
    
bind pub - !prehelp helpme

proc helpme {nick uhost hand chan args} {
        putserv "NOTICE $nick : Valid commands are !pre, groupnukes <group>"
        putserv "NOTICE $nick : Special Commands are !group <group>, !hour,!db"
        putserv "NOTICE $nick : Type them into the channel to learn more about them."
}

if {[file exists /usr/lib/tcltk/mysqltcl-3.05/libmysqltcl3.05.so]} {
    load /usr/lib/tcltk/mysqltcl-3.05/libmysqltcl3.05.so
}
####################################END OF SCRIPT###############################
putlog "PRE v2 by cburns successfully loaded"