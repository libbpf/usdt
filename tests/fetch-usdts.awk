# SPDX-License-Identifier: BSD-2-Clause

function reset_entry()
{
	entry = "";
	grp  = "???";
	name = "???";
	base = "???";
	sema = "???";
	args = "???";
	argn = 0;
}

function print_entry()
{
	if (base != 0 && !(base in basemap)) {
		basemap[base] = ++base_cnt;
	}
	if (sema != 0 && !(sema in semamap)) {
		semamap[sema] = ++sema_cnt;
	}
	base_stub = (base == 0) ? "0" : sprintf("BASE%d", basemap[base]);
	sema_stub = (sema == 0) ? "0" : sprintf("SEMA%d", semamap[sema]);
	printf "%s:%s base=%s sema=%s argn=%d args=%s.\n",
	       grp, name, base_stub, sema_stub, argn, args;
}

BEGIN {
	reset_entry();
}

#  stapsdt              0x0000003b       NT_STAPSDT (SystemTap probe descriptors)
#    Provider: test
#    Name: name4
#    Location: 0x0000000000401198, Base: 0x0000000000402043, Semaphore: 0x0000000000000000
#    Arguments: -4@$1 -4@$2 -4@$3 -4@$4

/\sstapsdt\s/ {
	if (entry != "") {
		print_entry();
		reset_entry();
	}
	entry = $0;
	next
}

/Provider:/ { grp = $2; }
/Name:/ { name = $2; }
/Location:/ { base = strtonum($4); sema = strtonum($6); }
/Arguments:/ { argn = NF - 1; args = (argn > 0) ? substr($0, index($0,$2)) : ""; }

END {
	if (entry != "")
	{
		print_entry();
	}
}
