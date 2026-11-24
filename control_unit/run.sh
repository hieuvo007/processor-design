#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
mkdir -p control_unit/build
run_lab() {
    local lab="$1" top
    local -a args
    case "$lab" in
        2) top=tb_lab02; args=(control_unit/lab02/*.sv control_unit/tb/tb_lab02.sv) ;;
        4) top=tb_lab04; args=(control_unit/lab04/control_unit_lab04.sv control_unit/tb/tb_lab04.sv) ;;
        5|6) top=tb_enhanced
             args=("-Ptb_enhanced.WITH_FPU=$((lab-5))" "control_unit/lab0$lab/control_unit_lab0$lab.sv" control_unit/tb/tb_enhanced.sv) ;;
        *) echo "Usage: bash control_unit/run.sh {2|4|5|6|all}" >&2; return 2 ;;
    esac
    local out="control_unit/build/lab0$lab.vvp"
    iverilog -g2012 -s "$top" -o "$out" "${args[@]}"
    vvp "$out"
}
if [[ "${1:-all}" == all ]]; then
    for n in 2 4 5 6; do run_lab "$n"; done
else
    run_lab "$1"
fi
