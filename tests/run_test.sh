#!/bin/bash
# SPDX-License-Identifier: BSD-2-Clause

set -euo pipefail

if [ "${V:-0}" -eq 1 ]; then
	set -x
fi

TIMEOUT=10

awk=${AWK:-awk}
readelf=${READELF:-readelf}
bpftrace=${BPFTRACE:-bpftrace}

TEST=$1
TEST_USDTS_SPEC=$TEST.exp_usdts.txt
TEST_USDTS_OUT=$TEST.act_usdts.txt
TEST_PRE_SPEC=$TEST.exp_pre_out.txt
TEST_PRE_OUT=$TEST.act_pre_out.txt
TEST_BTSCRIPT=$TEST.bt
TEST_BTOUT_SPEC=$TEST.exp_bt_out.txt
TEST_BTOUT_RAW=$TEST.act_bt_out_raw.txt
TEST_BTOUT=$TEST.act_bt_out.txt
TEST_OUT_SPEC=$TEST.exp_out.txt
TEST_OUT=$TEST.act_out.txt

$TEST -U > $TEST_USDTS_SPEC
$readelf -n $TEST 2>/dev/null | $awk -f fetch-usdts.awk > $TEST_USDTS_OUT
if ! $awk -f check-match.awk $TEST_USDTS_SPEC $TEST_USDTS_OUT; then
	echo "USDT SPECS FAILURE:"
	echo "EXPECTED:"
	cat $TEST_USDTS_SPEC
	echo "ACTUAL:"
	cat $TEST_USDTS_OUT
	exit 1
fi

$TEST -t > $TEST_PRE_SPEC
$TEST > $TEST_PRE_OUT
if ! $awk -f check-match.awk $TEST_PRE_SPEC $TEST_PRE_OUT; then
	echo "TEST PRE-ATTACH OUTPUT CHECK FAILURE:"
	echo "EXPECTED:"
	cat $TEST_PRE_SPEC
	echo "ACTUAL:"
	cat $TEST_PRE_OUT
	exit 1
fi

$TEST -b | $awk -v TEST=$TEST -f prepare-bt-script.awk > $TEST_BTSCRIPT
$TEST -B > $TEST_BTOUT_SPEC

if [ -s "$TEST_BTSCRIPT" ]; then
	# start attaching bpftrace
	setsid sudo $bpftrace -B none "$TEST_BTSCRIPT" >"$TEST_BTOUT_RAW" 2>&1 &
	bt_pid=$!
	bt_pgid="$(ps -opgid= "$bt_pid" | tr -d ' ')"

	# wait for bpftrace to finish attachment
	bt_start=$(date +%s)
	while true; do
		bt_elapsed=$(( $(date +%s) - bt_start ))
		if grep -q "STARTED!" "$TEST_BTOUT_RAW"; then
			break
		elif [ "$bt_elapsed" -ge "$TIMEOUT" ]; then
			sudo kill -KILL -$bt_pgid 2>/dev/null
			echo "BPFTRACE STARTUP TIMEOUT!"
			echo "BPFTRACE SCRIPT:"
			cat "$TEST_BTSCRIPT"
			echo "BPFTRACE OUTPUT:"
			cat "$TEST_BTOUT_RAW"
			exit 1
		elif ! kill -s 0 "$bt_pid"; then
			echo "BPFTRACE STARTUP FAILURE!"
			echo "BPFTRACE SCRIPT:"
			cat "$TEST_BTSCRIPT"
			echo "BPFTRACE OUTPUT:"
			cat "$TEST_BTOUT_RAW"
			exit 1
		else
			sleep 0.2
		fi
	done

	# get test output while bpftrace is attached
	$TEST &>"$TEST_OUT"

	sudo kill -INT -$bt_pgid 2>/dev/null

	$awk '/STARTED!/ {flag=1; next} /DONE!/ {flag=0} flag' $TEST_BTOUT_RAW > $TEST_BTOUT
	$awk -f check-match.awk $TEST_BTOUT_SPEC $TEST_BTOUT

	$TEST -T > $TEST_OUT_SPEC
	$awk -f check-match.awk $TEST_OUT_SPEC $TEST_OUT
fi
