set FLIST_PATH xilinx_flist
set ffd [open "$FLIST_PATH" r]
set FILELIST [list]
set INC_PATH [list]

while {![eof $ffd]} {
    [gets $ffd ffdline]
	set ffdmatch [regexp {^\+} $ffdline]
	if { $ffdmatch } {
		set nline [string range $ffdline 8 end]
		lappend INC_PATH $nline
	} elseif {$ffdline != "" } {
		lappend FILELIST $ffdline
	}
	puts stdout $ffdline
}

close $ffd

