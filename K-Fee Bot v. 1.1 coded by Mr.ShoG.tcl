################################################################################
# K-Fee Bot v. 1.1 coded by Mr.ShoG                                                          #
# Mr.ShoG (C) 2006                                                                        #
################################################################################
#                                                                                                                                           #
# Edit the variables below to match your mysql configuration                      #
#                                                                                                                                        #
################################################################################

set mysql_(user) "*******"
set mysql_(password) "*******"
set mysql_(host) "*******"
set mysql_(db) "*******"
set mysql_(table) "*******"
set mysql_(craptable) "*******"

set db_(rlsname) "*******"
set db_(section) "*******"
set db_(status) "*******"
set db_(reason) "*******"
set db_(id) "*******"
set db_(time) "*******"
set db_(files) "*******"
set db_(size) "*******" 
set db_(nick) "*******"
set db_(genre) "*******"

################################################################################
#                                                                                                                                           #
# Edit the variables below to match some other configuration                      #
#                                                                                                                                        #
################################################################################

# Channel Settings

set addprechan "#relsplex"
set staffchan "#relsplex"
set spamchan "#relsplex"

# Prefixes for announce
set prefix_(site) "3P9.10R9.3E"
set prefix_(nuke) "\0034NUKE\003"
set prefix_(unnuke) "\0033UNNUKE\003"

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
set data [open "[pwd]/filter.txt" r+]
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


proc ms:cmdlist { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      putserv "PRIVMSG $chan : \002Befehllist für Biatch\002"
      putserv "PRIVMSG $chan : !addpre <release> <section>"
      putserv "PRIVMSG $chan : !info <release> <files> <size>"
      putserv "PRIVMSG $chan : !addgenre <release> <genre>"
      putserv "PRIVMSG $chan : !chgsec <release> <newsection>"
      putserv "PRIVMSG $chan : !nuke <release> <reason>"
      putserv "PRIVMSG $chan : !unnuke <release> <reason>"
      putserv "PRIVMSG $chan : !delpre <release> \002(\002\0034\002Use this for pre.spam\002\003\002)\002"
      putserv "PRIVMSG $chan : !oldadd <release> <section> <unixtime>"
      putserv "PRIVMSG $chan : !readd <release> <section> <YYYY-MM-DD> <HH:MM:SS>"
      putserv "PRIVMSG $chan : !spamchan \002(\002Invites you to Spamchannel\002)\002"
  }
}

proc ms:invite { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        set spamchan "#relsplex"
        putquick "INVITE $nick $spamchan"
        putquick "PRIVMSG $chan : $nick successfully invited to spamchan"
        putlog "--INVITE-- $nick invites himself to $spamchan"
  }
}


proc highlight_string {strin subject pre past} {
    return [regsub -all -- $strin $subject "$pre\\0$past"] }
   

proc ms:dupe {nick uhost hand chan arg} { 
  set chan [string tolower $chan]
  if {[channel get $chan search]} {
      global mysql_ db_
        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
        set query1 [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%$sea1%' ORDER BY $db_(time) DESC LIMIT 20" -flatlist];
          if {$query1 == ""} {
              putquick "PRIVMSG $chan : nothing found for $arg"
          } elseif {$query1 != ""} {
              putquick "PRIVMSG $chan : Sending $nick Search Result"
              putquick "PRIVMSG $nick : Your Top 20 results for \"\002$sea1\002\""
          foreach {rls type files mb status reason timestamp} $query1 { 
          set rls [highlight_string $sea1 $rls \002 \002]
          set time1 [unixtime]
          incr time1 -$timestamp
          set ago [duration $time1] 
                if { $status == "1"} {
                  putquick "PRIVMSG $nick : [clock format $timestamp -format "%Y-%m-%d %H:%M:%S"] $rls NUKED: $reason"
                } elseif { $status == "0" } {
                  putquick "PRIVMSG $nick : [clock format $timestamp -format "%Y-%m-%d %H:%M:%S"] $rls "
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
  set chan [string tolower $chan]
  if {[channel get $chan search]} {
      global mysql_ db_
        set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -pass $mysql_(password) -db $mysql_(db)];
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
            incr time1 $timestamp
            set ago [duration $time1]
            set after [clock clicks -milliseconds]
              if {$nuke == "0"} {
              set f "FiLES"
              set m "MB"
                  putquick "PRIVMSG $chan :\[\002PRE\002\] ( \0033$type\003 ) -- $rls  ( [ ] ) ( [ ] ) with ( $files$f ) ( $mb$m ) -- pred $ago ago"
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
    putquick "NOTICE $nick :  This takes $duration1$ms"
  mysqlclose $handle
      }
    }
  }
}

proc ms:addpre { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !addpre <release> <section>"
      } else {
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\{"]
          set fee_(release) [string trimright $fee_(release) "\}"]
          set fee_(section) [lrange $splitz 1 1]
          set fee_(section) [string trimleft $fee_(section) "\{"]
          set fee_(section) [string trimright $fee_(section) "\}"]       
              if { $fee_(section) == "" } {
                putquick "NOTICE $nick : \[\002ERROR\002\] No section set!"
              } else {
                global addprechan               
                          putquick "PRIVMSG $chan : \[\002ADDPRE\002\] $nick add $fee_(release) - $fee_(section)"
                          putquick "PRIVMSG $addprechan : !addpre $fee_(release) $fee_(section)"
                    }
            }
      }   
    set chan [string tolower $chan]                                       
    if {[channel get $chan add]} {
          global prefix_ mysql_ db_ crap_ spamvar spamturn staffchan     
          if {[lsearch $spamvar [lindex $arg 0]] == "-1"} {
          set spamvar [lreplace $spamvar $spamturn $spamturn [lindex $arg 0]]
          incr spamturn
          if {$spamturn >= 29} {set spamturn 0}
              set splitz [split $arg " "]
              set add_(release) [lrange $splitz 0 0]
              set add_(release) [string trimleft $add_(release) "\\\{"]
              set add_(release) [string trimright $add_(release) "\\\}"]
              set add_(section) [lrange $splitz 1 1]
              set add_(section) [string trimleft $add_(section) "\\\{"]
              set add_(section) [string trimright $add_(section) "\\\}"]
              set add_(nick) $nick
          set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'"]                         
          mysqlclose $mysql_(handle)
            if { $numrel != 0 } {
            } else {
              set add_(time) [clock seconds]
              set temp1 [split $add_(release) -]
              set group [lindex $temp1 end]
              set crap 0
              set crapo 0
              set rlsl [string length $add_(release)]
              global crapwords
              foreach word $crapwords { set crap [expr $crap + [string match -nocase $word $add_(release) ]] }
                    if { $group == "iND" || $group == " " || $crap != 0 || $rlsl <= 13 } {                           
                      set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                      set temp4 [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(craptable) ($db_(section),$db_(rlsname),$db_(time)) VALUES ( '$add_(section)' , '$add_(release)' , '$add_(time)')"]                                           
                      putlog "--CRAP-- Move $add_(release) into Craptable use !move $add_(release) to readd it"
                      putquick "PRIVMSG $staffchan : \[\002CRAP\002\] by $nick !move $add_(release)"
                      putquick "PRIVMSG $chan : \[\002FILTER\002\] $add_(release) has been filtered for randrom reasons"
                      mysqlclose $mysql_(handle)
                      set crapo 1 }
                        if { $crapo == 0 } {
                          array set section_replace {
                                "*TV*"           "TV"
                                "*SERIE*"    "TV"
                                "*0?DAY*"    "0DAY"
                                "*IMGSET*"    "0DAY"
                                "xv?d*"      "XVID"
                                "d?vx*"         "DIVX"
                                "*EBOOK*"    "eBook"
                                "*PHOTOS*"    "0DAY"
                                "*COVER*"    "COVERS"
                                "*MV*"        "MVID"
                                "*MV?D*"      "MVID"
                                "N/A"        "UNKNOWN"
                                "-"          "UNKNOWN"
                                "PRE"        "UNKNOWN"
                                "*MP3*"      "MP3"
                                "DVDR*"         "DVDR"
                                "MDVDR*"      "DVDR"
                                "*XXX*"      "XXX"
                                "*TV*"        "TV"
                                "*UTIL*"      "APPS"                                                     
                              }
                              foreach {section replace} [array get section_replace] {
                                if {[string match -nocase $section $add_(release)]} {
                                    set old_(section) "$add_(section)"
                                    set add_(section) "$replace"
                                    putlog "--CHGSEC-- Change section from $old_(section) to $add_(section)" }
          }                                                                             
        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'"]                         
        mysqlclose $mysql_(handle)
            if { $numrel == 0 } {
                set add_(time) [clock seconds]
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set nix [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(time),$db_(nick)) VALUES ( '$add_(section)' , '$add_(release)' , '$add_(time)' , '$nick' )"]
                putlog "--ADD-- $add_(release) was successfully added by $nick"
                mysqlclose $mysql_(handle) }
                      set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                      set q [mysqlsel $mysql_(handle) "SELECT name,section FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'" ]
                      mysqlmap $mysql_(handle) { name section } {
                          mysqlclose $mysql_(handle)
                          global spamchan
                            if {[string match -nocase "*GERMAN*" $name]} {
                                putquick "PRIVMSG $spamchan : $prefix_(site) - (\0033 $section\003 ) - \002\0030$name\003\002"
                            } else {
                                putquick "PRIVMSG $spamchan : $prefix_(site) - (\0033 $section\003 ) - $name" }
                    }
    }                                                                                     
  }
}
}


bind pub -|- !move ms:move

proc ms:move { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !move <release>"
      } else {
          set splitz [split $arg " "]
          set move_(release) [lrange $splitz 0 0]
          set move_(release) [string trimleft $move_(release) "\\\{"]
          set move_(release) [string trimright $move_(release) "\\\}"]
          global mysql_  db_
          set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
          set q [mysqlsel $mysql_(handle) "SELECT name,section,timestamp FROM $mysql_(craptable) WHERE $db_(rlsname) = '$move_(release)'" ]
          mysqlmap $mysql_(handle) { name section timestamp } {
          set nix [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(time)) VALUES ( '$section' , '$name' , '$timestamp')"]
          set nix [mysqlexec $mysql_(handle) "DELETE FROM $mysql_(craptable) WHERE $db_(rlsname)='$move_(release)'"]
          mysqlclose $mysql_(handle)
              putquick "PRIVMSG $chan : $nick successfully moved\002\0030 $move_(release)\003\002 back to my DB"
        }
    }
  }
}

proc delpre {nick uhost handle channel arg} {
    global sql adminchan botmaster
    regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037} $arg {} arg    
    set timestamp [clock seconds]
    set arg [split $arg " "]
    set release [string last - [lindex $arg 0]]
    set group [string range [lindex $arg 0] [expr $release + 1] end]
    set deldelay [clock clicks -m]
    if { $arg == "" } {
          putquick "NOTICE $nick :Syntax is: !delpre release, Use it and you will get a Result :)"
      return 0
  }
    set isindb [mysqlsel $sql(handle) "SELECT `$sql(mysqltimefield)` , `$sql(mysqlrelnamefield)` , `$sql(mysqlgroupnamefield)` , `$sql(mysqlsectionnamefield)` , `$sql(mysqlbotnamefield)` , `$sql(mysqlprehqnamefield)` FROM `$sql(mysqltablename)` WHERE $sql(mysqlrelnamefield)='[lindex $arg 0]'"]
    if {$isindb != "0"} {
    set delcheck [mysqlexec $sql(handle) "DELETE FROM `$sql(mysqltablename)` WHERE name = '[lindex $arg 0]';"]
    if { $delcheck == "1" } {
            puthelp "PRIVMSG $channel :\[\00314DELPRE\003\]: $timestamp \002::\002 [lindex $arg 0]"
            puthelp "PRIVMSG $adminchan :\[\00314DELPRE\003\]: $timestamp \002::\002 [lindex $arg 0] by \[\00314$nick\003/\00314$channel\003/\00314[expr [clock clicks -m] - $deldelay]\ms\003\]"
          mysqlmap $sql(handle) { timefield } {
    set crapdel [mysqlexec $sql(handle) "INSERT INTO `$sql(mysqlcraptablename)` ( `$sql(mysqltimefield)` , `$sql(mysqlrelnamefield)` , `$sql(mysqlsectionnamefield)` , `$sql(mysqlgroupnamefield)` , `$sql(mysqlbotnamefield)` , `$sql(mysqlprehqnamefield)` ) VALUES ( '$sql(mysqltimefield)', '[lindex $arg 0]', '$sql(mysqlsectionnamefield)', '$group', '$sql(mysqlbotnamefield)', '$sql(mysqlprehqnamefield)')"]
            putquick "PRIVMSG $botmaster :\[\00314CRAPDEL\003\]: [lindex $arg 0] moved by \[\00314$nick\003/\00314$channel\003/\00314[expr [clock clicks -m] - $deldelay]\ms\003\] - (Use: !move [lindex $arg 0])"
    } else {
            puthelp "PRIVMSG $channel :No such Release in Database!"            
            }
        }
    }
}


bind pub -|- !craptable ms:craptable

proc ms:craptable { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
          global mysql_ db_
          set splitz [split $arg " "]
          set crap_(table) [lrange $splitz 0 0]
          set crap_(table) [string trimleft $crap_(table) "\\\{"]
          set crap_(table) [string trimright $crap_(table) "\\\}"]
          if {[string is integer -strict $crap_(table)] == 0 } {
              putquick "NOTICE $nick : !craptable X"
              putquick "NOTICE $nick : X must bei a number 1-20"
          } else {
            if { $crap_(table) >= 20 } {
                putquick "NOTICE $nick : Maximum reached!"
          } else {
            if { $crap_(table) == "" } {
                putquick "NOTICE $nick : No X given. Set X to 5"
          } else {         
                putquick "PRIVMSG $chan : Showing $crap_(table) records:"
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set w [mysqlsel $mysql_(handle) "SELECT name,section,timestamp FROM $mysql_(craptable) WHERE $db_(rlsname) LIKE '%' ORDER BY $db_(time) ASC LIMIT 0,$crap_(table)"]
                mysqlmap $mysql_(handle) { name section timestamp } {
                  putquick "PRIVMSG $chan : $section - $name - $timestamp"
                  }
            }
    }
  }
} 
mysqlclose $mysql_(handle)
}

bind pub -|- !crapdel ms:crapdel

proc ms:crapdel { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !crapdel <release>" }
      if { $arg != "" } {
          set splitz [split $arg " "]
          regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036} $splitz {} splitz
          set cdel_(release) [lrange $arg 0 0]
          set cdel_(release) [string trimleft $cdel_(release) "\\\{"]
          set cdel_(release) [string trimright $cdel_(release) "\\\}"]
            global mysql_ prefix_ db_
            set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
            set q "SELECT $db_(id) FROM $mysql_(craptable) WHERE $db_(rlsname) = '$cdel_(release)'"
            set numrel [mysqlsel $handle $q]
            mysqlclose $handle
                if { $numrel == 0 } {
                    putquick "PRIVMSG $chan : Sorry $nick ! \002$cdel_(release)\002 was not found in CrapDB." }
                if { $numrel != 0 } {
                    set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                    set q "DELETE FROM $mysql_(craptable) WHERE $db_(rlsname)='$cdel_(release)'"
                    set nix [mysqlexec $handle $q]
                    mysqlclose $handle
                        putquick "PRIVMSG $chan : \002$nick\002 deletes ( \002$cdel_(release)\002 ) from CrapDB!"
                        putlog "--CDEL-- $cdel_(release) by $nick" }
  }
}
}

bind pub -|- !crapclean ms:crapclean

proc ms:crapclean { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
            global mysql_ prefix_ db_
                    set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                    set q "DELETE FROM $mysql_(craptable) WHERE $db_(rlsname) LIKE '%'"
                    set nix [mysqlexec $handle $q]
                    mysqlclose $handle
                      set w "SELECT COUNT(id) as anzahl from $mysql_(craptable)"
                      set numrel2 [mysqlsel $handle $w]
                      mysqlmap $handle { crapanzahl } {
                        putquick "PRIVMSG $chan : $crapanzahl Releases deleted from CrapDB!"
                        putlog "--CLEAN-- CRAPDB was cleaned by $nick" }
    }
  mysqlclose $handle 
}   

proc ms:nuke { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !nuke <release> <reason>"
        } else {
          global mysql_ db_ addprechan
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(reason) [lrange $splitz 1 1]
          set fee_(reason) [string trimleft $fee_(reason) "\\\{"]
          set fee_(reason) [string trimright $fee_(reason) "\\\}"]
              if { $fee_(reason) == "" } {
                  putquick "NOTICE $nick : No Reason set!"
              } else {
                  global addprechan
                  putquick "PRIVMSG $chan : \[\002\0033NUKE\003\002\] $fee_(release) with reason: $fee_(reason)"
                  #putquick "PRIVMSG $addprechan : !nuke $fee_(release) $fee_(reason)" }
              }
          }
    set chan [string tolower $chan]                                       
    if {[channel get $chan add]} {
      global mysql_ db_ prefix_ nukevar nuketurn
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
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$nuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $nuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                    mysqlclose $mysql_(handle)
                        if { $numrel != 0 && $rskip != 1 } {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=1, $db_(reason)='$nuke_(reason)' WHERE $db_(rlsname)='$nuke_(release)'"
                            mysqlclose $mysql_(handle)
                                putlog "--NUKE-- $nuke_(release) nuked with reason $nuke_(reason)"
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                            set q [mysqlsel $mysql_(handle) "SELECT name,section,reason FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason } {
                                mysqlclose $mysql_(handle)
                                  global spamchan
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putquick "PRIVMSG $spamchan : $prefix_(nuke) ( \0035$group\003 ) -> (\0033 $section\003 ) - $name - (\037\0034$reason\037\003)" }
                          }
              }
    }
  }
}
}       

proc ms:unnuke { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !unnuke <release> <reason>"
        } else {
          global mysql_ db_ addprechan
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(reason) [lrange $splitz 1 1]
          set fee_(reason) [string trimleft $fee_(reason) "\\\{"]
          set fee_(reason) [string trimright $fee_(reason) "\\\}"]
              if { $fee_(reason) == "" } {
                  putquick "PRIVMSG $chan : No Reason set!"
              } else {
                  global addprechan
                    putquick "PRIVMSG $chan : \[\002\0033UNNUKE\003\002\] $fee_(release) with reason: $fee_(reason)"
                    #putquick "PRIVMSG $addprechan : !unnuke $fee_(release) $fee_(reason)" }
              }
          }
    set chan [string tolower $chan]                                       
    if {[channel get $chan add]} {
      global mysql_ db_ prefix_ unnukevar unnuketurn
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
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$unnuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$unnuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $unnuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                    mysqlclose $mysql_(handle)
                        if { $numrel != 0 } {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=0, $db_(reason)='$unnuke_(reason)' WHERE $db_(rlsname)='$unnuke_(release)'"
                            mysqlclose $mysql_(handle)
                                putlog "--UNNUKE-- $unnuke_(release) unnuked with reason $unnuke_(reason)"
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                            set q [mysqlsel $mysql_(handle) "SELECT name,section,reason FROM $mysql_(table) WHERE $db_(rlsname) = '$unnuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason } {
                                mysqlclose $mysql_(handle)
                                  set spamchan "#k-fee.spam"
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putquick "PRIVMSG $spamchan : $prefix_(unnuke) ( \0035$group\003 ) -> (\0033 $section\003 ) - $name - (\037\0033$reason\037\003)" }
                      }
            }
  }
}
}
                   
bind time -|- "00 * * * *" ms:hour
bind pub -|- !hour ms:hour

proc ms:hour { min hour day month year } {
        global mysql_ db_
        set now [clock seconds]
        set dur [expr $now - 3600]
        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
        set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(time) > $dur"
        set numrel [mysqlsel $mysql_(handle) $q]
        set w "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%' AND $db_(status)=1 AND $db_(time) > $dur"
        set nukerel [mysqlsel $mysql_(handle) $w]
            putquick "PRIVMSG #k-fee.spam : 3H9.10O9.10U9.3R - Last hour we had\0034 $numrel\003 Pres"
            putquick "PRIVMSG #k-fee.spam : 3H9.10O9.10U9.3R -\0034 $nukerel\003 of them are marked ase nuked"
            putlog "--HOURSTATS-- Added: $numrel Nuke: $nukerel"
  }

proc ms:info { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !addinfo <release> <files> <size>"
        } else {
          global mysql_ db_ addprechan
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(files) [lrange $splitz 1 1]
          set fee_(files) [string trimleft $fee_(files) "\\\{"]
          set fee_(files) [string trimright $fee_(files) "\\\}"]
          set fee_(size) [lrange $splitz 2 2]
          set fee_(size) [string trimleft $fee_(size) "\\\{"]
          set fee_(size) [string trimright $fee_(size) "\\\}"]
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                    mysqlclose $mysql_(handle)
                        if { $numrel == 0 } {
                            putquick "PRIVMSG $chan : \002$fee_(release)\002 not found in my DB"
                          } else {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            set one "1"
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(files)='$fee_(files)', $db_(size)='$fee_(size)' WHERE $db_(rlsname)='$fee_(release)'"
                            mysqlclose $mysql_(handle)
                                putquick "PRIVMSG $chan : $nick addinfo for (\002 $fee_(release) \002) with (\002 $fee_(files) FiLES \002) (\002 $fee_(size) MB \002)"
                                #putquick "PRIVMSG $addprechan : !unnuke $fee_(release) $fee_(reason)" }
                        }
                }
    set chan [string tolower $chan]
    if {[channel get $chan add]} {   
          global mysql_ db_ infovar infoturn
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
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$info_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                    mysqlclose $mysql_(handle)
                        if { $numrel == 0 } {
                          } else {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(files)='$info_(files)' , $db_(size)='$info_(size)' WHERE $db_(rlsname)='$info_(release)'"]
                            putlog "--INFO-- Add info for $info_(release) - $info_(files)Files $info_(size)MB"
                            mysqlclose $mysql_(handle)
          }
    }
}
}
                   
bind pub -|- !delpre ms:delpre
bind pub -|- !del ms:delpre

proc ms:delpre { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !delpre <release>" }
      if { $arg != "" } {
          set splitz [split $arg " "]
          regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036} $splitz {} splitz
          set del_(release) [lrange $arg 0 0]
          set del_(release) [string trimleft $del_(release) "\\\{"]
          set del_(release) [string trimright $del_(release) "\\\}"]
            global mysql_ prefix_ db_
            set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
            set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
            set numrel [mysqlsel $handle $q]
            mysqlclose $handle
                if { $numrel == 0 } {
                    putquick "PRIVMSG $chan : Sorry $nick ! \002$del_(release)\002 was not found in Database." }
                if { $numrel != 0 } {
                    set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                    mysqlsel $handle "SELECT $db_(section),$db_(nick),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
                    mysqlmap $handle { dbsection dbnick dbtime } {
                    set q "DELETE FROM $mysql_(table) WHERE $db_(rlsname)='$del_(release)'"
                    set nix [mysqlexec $handle $q]
                    mysqlclose $handle
                    set staffchan "#fee.staff"
                        putquick "PRIVMSG $chan : \002$nick\002 deletes ( \002$del_(release)\002 ) added by ( \002$dbnick\002 ) ( \002$dbtime\002 ) from my DB"
                        putquick "PRIVMSG $staffchan : !oldadd $del_(release) $dbsection $dbtime"
                        putlog "--DEL-- $del_(release) by $nick" }
            }
      } 
  }
}       

proc ms:genre { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !addgenre <release> <genre>"
        } else {
          global mysql_ db_ addprechan
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(genre) [lrange $splitz 1 1]
          set fee_(genre) [string trimleft $fee_(genre) "\\\{"]
          set fee_(genre) [string trimright $fee_(genre) "\\\}"]
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                    mysqlclose $mysql_(handle)
                        if { $numrel == 0 } {
                            putquick "PRIVMSG $chan : \002$fee_(release)\002 not found in my DB"
                          } else {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$fee_(genre)' WHERE $db_(rlsname)='$fee_(release)'"
                            mysqlclose $mysql_(handle)
                                putquick "PRIVMSG $chan : $nick addgenre for (\002 $fee_(release) \002) (\002 $fee_(genre) \002)"
                                #putquick "PRIVMSG $addprechan : !addgenre $fee_(release) $fee_(genre)" }
                        }
                }
    set chan [string tolower $chan]
    if {[channel get $chan add]} {   
          global mysql_ db_ genrevar genreturn
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
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$genre_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                    mysqlclose $mysql_(handle)
                        if { $numrel == 0 } {
                          } else {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$genre_(genre)' WHERE $db_(rlsname)='$genre_(release)'"]
                            putlog "--GENRE-- Add genre for $genre_(release) - $genre_(genre)"
                            mysqlclose $mysql_(handle)
          }
    }
}
}                     
                     
bind pub -|- !chgsec ms:chgsec

proc ms:chgsec { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !chgsec <release> <newsection>"
        } else {
          global mysql_ db_
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(newsec) [lrange $splitz 1 1]
          set fee_(newsec) [string trimleft $fee_(newsec) "\\\{"]
          set fee_(newsec) [string trimright $fee_(newsec) "\\\}"]
                set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                    mysqlclose $mysql_(handle)
                        if { $numrel == 0 } {
                            putquick "PRIVMSG $chan : \002$fee_(release)\002 not found in my DB"
                          } else {
                            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]                         
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(section)='$fee_(newsec)' WHERE $db_(rlsname)='$fee_(release)'"
                            mysqlclose $mysql_(handle)
                                putquick "PRIVMSG $chan : $nick changes section (\002 $fee_(release) \002) to (\002 $fee_(newsec) \002)"
                              }
                        }
                }
}                 
                     
bind pub -|- !readd ms:readd

proc ms:readd { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == "" } {
          putserv "NOTICE $nick : \002Syntax is\002 !readd <release> <section> <unixtime>"
      } else {
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\{"]
          set fee_(release) [string trimright $fee_(release) "\}"]
          set fee_(section) [lrange $splitz 1 1]
          set fee_(section) [string trimleft $fee_(section) "\{"]
          set fee_(section) [string trimright $fee_(section) "\}"]       
          set fee_(unixtime) [lrange $splitz 2 2]
          set fee_(unixtime) [string trimleft $fee_(unixtime) "\{"]
          set fee_(unixtime) [string trimright $fee_(unixtime) "\}"]         
              if { $fee_(section) == "" } {
                putquick "PRIVMSG $chan : No time set!"
              } else {               
              global mysql_ db_ addprechan
              set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
              set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
              set numrel [mysqlsel $mysql_(handle) $q]
                mysqlclose $mysql_(handle)
                  if { $numrel != 0 } {
                    putquick "PRIVMSG $chan : \002$fee_(release)\002 is already in my DB"
                  } else {
                    set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]         
                    set nix [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(time)) VALUES ( '$fee_(section)' , '$fee_(release)' , '$fee_(unixtime)')"]
                          putquick "PRIVMSG $chan : $nick added ( \002$fee_(release)\002 ) - ( \002$fee_(section)\002 ) -( \002$fee_(unixtime)\002 )"
                          #putquick "PRIVMSG $addprechan : !readd $fee_(release) $fee_(unixtime)"
                    mysqlclose $mysql_(handle) }
                }
              }
      }
}       


bind pub - !oldadd oldadd

proc oldadd { nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan db]} {
      if { $arg == " " } {
          putserv "NOTICE $nick : Syntax is !oldadd <release> <section> <YYYY-MM-DD> <HH:MM-SS>"
      } else {
            set splitz [split $arg " "]
            set old_(release) [lrange $splitz 0 0]
            set old_(release) [string trimleft $old_(release) "\\\{"]
            set old_(release) [string trimright $old_(release) "\\\}"]
            set old_(section) [lrange $splitz 1 1]
            set old_(section) [string trimleft $old_(section) "\\\{"]
            set old_(section) [string trimright $old_(section) "\\\}"]           
                set old_(date) [lrange $splitz 2 2]
                set old_(date) [string trimleft old_(date) "\\\{"]
                set old_(date) [string trimright old_(date) "\\\}"]
                set old_(time) [lrange $splitz 3 3]
                set old_(time) [string trimleft old_(time) "\\\{"]
                set old_(time) [string trimright old_(time) "\\\}"]
                set unxtime [clock scan $old_(date) $old_(time)] }
                    global mysql_ db_ prefix_
                    set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                    set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$old_(release)'"
                    set numrel [mysqlsel $handle $q]
                    mysqlclose $handle
                    if { $numrel != 0 } {
                        putserv "PRIVMSG $chan : Sorry $nick ! /002$old_(release)/002 already found in Database" }
                    if { $numrel == 0 } {
                        set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                        set q "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(time)) VALUES ('$old_(section)' , '$old_(release)' , '$unixtime')"
                        set nix [mysqlexec $handle $q]
                        mysqlclose $handle
                            putserv "PRIVMSG $chan : \002( $old_(section) )\002 -- \002( $old_(release) )\002 with time \002( $old_(date) ) ( $old_(time) )\002 was successfully added by $nick"
                            putlog "--READD-- $old_(section) -- $old_(release)"
  }
}
}           
                     

bind pub -|- !groupnukes ms:groupnukes

proc ms:groupnukes {nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan stats]} {
        if { $arg == "" } {
          putquick "PRIVMSG $chan : No group set!"
        } else {
          global mysql_ db_
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set group [string trimright $group "\\\}"]
          set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$group'"]
          mysqlclose $mysql_(handle) 
              if { $numrel == 0 } {
                putquick "PRIVMSG $chan : No Release found for $arg"
              } else {
              putquick "PRIVMSG $chan : \[\002\0032\$arg\002\0032\] $arg has $numrel nuked Releases in my DB"
              putquick "PRIVMSG $chan : \[\002\0032\$arg\002\0032\] Showing last 5 Nukes:"
              set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
              set q [mysqlsel $mysql_(handle) "SELECT name,section,status,reason FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$arg' AND $db_(status)=1 ORDER BY $db_(time) DESC LIMIT 0,5"]
              mysqlmap $mysql_(handle) { name section status reason } {
                  putquick "PRIVMSG $chan : \[\002\0032\$group\002\0032\] (\0033 $section \003) - $name -> (\037\0033$reason\037\003)"
                  }
      }
  }
}
mysqlclose $mysql_(handle)
}

                 
             
             

bind pub -|- !db ms:db

proc ms:db {nick uhost hand chan arg} {
    global mysql_ db_
      set handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)];
      set row [lindex [mysqlsel $handle "SHOW TABLE STATUS LIKE '$mysql_(table)';" -list] 0]
        set q "SELECT COUNT(id) as anzahl from $mysql_(table)"
      set numrel [mysqlsel $handle $q]
            mysqlmap $handle { anzahl } {
                  putquick "PRIVMSG $chan : \[\002DB\002\] -\0033 $anzahl\003 Releases in my DB! Using\002\0033 [format %.2f [expr [lindex $row 5] / 1024.0]] \003\002 KB."
      set row2 [lindex [mysqlsel $handle "SHOW TABLE STATUS LIKE '$mysql_(craptable)';" -list] 0]
      set w "SELECT COUNT(id) as anzahl from $mysql_(craptable)"
      set numrel2 [mysqlsel $handle $w]
          mysqlmap $handle { crapanzahl } {
              putquick "PRIVMSG $chan : \[\002DB\002\] -\0033 $crapanzahl\003 Releases in my CrapDB! Using\002\0033 [format %.2f [expr [lindex $row2 5] / 1024.0]] \003\002 KB."

  }
}
}

bind pub -|- !stats ms:stats

proc ms:stats {nick uhost hand chan arg } {
    set chan [string tolower $chan]
    if {[channel get $chan stats] } {
        global mysql_ db_
            set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
            set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) from $mysql_(table) WHERE $db_(rlsname) LIKE '%-$arg'"]
            mysqlclose $mysql_(handle)
            if { $numrel == 0 } {
                putquick "PRIVMSG $chan : no releases found by\002$arg\002 cannot found in DB"
            } else {     
                        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                        set internals [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%INTERNAL%-$arg'"]
                        set dirfixes [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%DIRFIX%-$arg'"]
                        set nukes [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%-$arg' AND $db_(status) =1"]
                        set temp1 [expr $numrel - $dirfixes - $internals - $nukes]
                        set temp1 "$temp1.00"
                        set quality [expr ( $temp1 / $numrel ) * 100]
                        set quality [expr round ($quality)]
                            putquick "PRIVMSG $chan : found \002$numrel\002 releases by \002$arg\002 (INTERNALS: \002$internals\002 NUKES: \002$nukes\002 FIXES: \002$dirfixes\002) so we have \002$quality\002 % fine releases from \002$arg\002"                                                     
                        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                        set oldest [mysqlsel $mysql_(handle) "SELECT name,timestamp from $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%-$arg' ORDER BY $db_(time) ASC LIMIT 0,1"]
                        mysqlmap $mysql_(handle) { name timestamp } {
                                set predate [clock format $timestamp -format %d.%m.%Y]
                                set pretime [clock format $timestamp -format %H:%M:%S]
                                putquick "PRIVMSG $chan : first release by \002$arg\002: $name @ $predate / $pretime"
                        }
                        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                        set newest [mysqlsel $mysql_(handle) "SELECT name,timestamp from $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%-$arg' ORDER BY $db_(time) DESC LIMIT 0,1"]
                        mysqlmap $mysql_(handle) { name timestamp } {
                                set predate [clock format $timestamp -format %d.%m.%Y]
                                set pretime [clock format $timestamp -format %H:%M:%S]
                                putquick "PRIVMSG $chan : last release by \002$arg\002: $name @ $predate / $pretime"
                        }
                        set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
                        set lastnuke [mysqlsel $mysql_(handle) "SELECT name,timestamp,reason from $mysql_(table) WHERE index=1 AND $db_(rlsname) LIKE '%-$arg' AND $db_(status) =1 ORDER BY $db_(time) DESC LIMIT 0,1"]
                        mysqlmap $mysql_(handle) { name timestamp reason } {
                                set predate [clock format $timestamp -format %d.%m.%Y]
                                set pretime [clock format $timestamp -format %H:%M:%S]
                                putquick "PRIVMSG $chan : last nuke by \002$arg\002: $name @ $predate / $pretime reason: \0034$reason\003"
                        }
                }
                mysqlclose $mysql_(handle)
        }
}

bind pub - !check checkit

proc checkit {nick uhost hand chan args} {
global askchan
#    if { $chan == $askchan }
    set chan [string tolower $chan]
    if {[channel get $chan search]} {
        global mysqlhost mysqluser mysqlpassword mysqldb color1 color2 color3 siteprefix
    set handle [mysqlconnect -host $mysqlhost -user $mysqluser -pass $mysqlpassword -db $mysqldb]
        set liste [split $args " "]
        set rlz [string trimleft [lrange $liste 0 0] "\\\{\}"]
        set quark [string trimright [lrange $liste 1 1] "\\\}\{"]
    set syntax 0
    set lowline "_"
    set star "%"
    if { $rlz == "" } { set syntax 1 }
    if { $quark != "" } { set syntax 1 }
    if { $syntax == 1 } {
        putserv "NOTICE $nick : !check Syntax: '\002!check Releasename\002'"
    }
    if { $syntax == 0 } {
    set wo "WHERE rlsname LIKE '$rlz'"
        set affro [mysqlsel $handle "select rlsname,ctime,nuketime,nukereason,section from sweetpre $wo"]
    if { $affro == 0 } {
        putserv "PRIVMSG $chan : $siteprefix - \002\[\003$color2 CHECK \003$color1\] \003$color3$rlz\003$color1\002 was not found in database."
    }
    if { $affro == 1 } {
            mysqlmap $handle { rlsname - ntime nreason section } {
            if { $ntime != 0 } {
                putserv "PRIVMSG $chan : $siteprefix - \002\[\002 \002\003$color2$section\002 \002\00300] \002-\> \002CHECK: \002 \[-\002\00304NUKED\00300\002-\] \003$color3\002 $rlz"
            }
            if { $ntime == 0 } {
                putserv "PRIVMSG $chan : $siteprefix - \002\[\002 \002\003$color2$section\002 \002\00300] \002-\> \002CHECK: \002 \[-\002\00309NOT NUKED\00300\002-\] \003$color3\002 $rlz"
            }
    }
  }
  }
  mysqlclose $handle
}
}

           
   
             
       


bind pub - !prehelp helpme

proc helpme {nick uhost hand chan args} {
        putserv "NOTICE $nick : Valid commands are !pre, !pred, !dupe, !check"
        putserv "NOTICE $nick : Special Commands are !group <group> !hourstats / !hour, !daystats / !day, !db"
        putserv "NOTICE $nick : Type them into the channel to learn more about them."
}


#set file libmysqltcl2.30

if {[file exists /usr/lib/mysqltcl-3.04/libmysqltcl3.04.so]} {
    load /usr/lib/mysqltcl-3.04/libmysqltcl3.04.so
} else {
    load ../libmysqltcl2.30.so
}

####################################END OF SCRIPT###############################

putlog "K-Fee Bot v. 1.1 (C) 2006 by Mr.ShoG successfully loaded"

##########################DONT REMOVE THIS FROM THIS SCRIPT !!!!################