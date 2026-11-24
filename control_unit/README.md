# Control Unit

This directory contains the Lab 2 finite-state machines and the SystemVerilog control units for Labs 4–6. Each processor lab includes a `processor_labXX.sv` module for connecting its control unit to the team's datapath.

- **Lab 2:** Sequence detectors and a Morse code controller.
- **Lab 4:** Basic instruction control for `mv`, `mvi`, `add`, and `sub`.
- **Lab 5:** Adds program counter control, memory access (`ld`, `st`), and conditional move (`mvnz`).
- **Lab 6:** Adds floating-point addition (`addf`).

The `tb/` directory contains standalone tests. Labs 5 and 6 share `tb_enhanced.sv`. Run all tests from the repository root with `bash control_unit/run.sh all`.
