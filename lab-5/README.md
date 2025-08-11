# ARM16 Lab 5 — CPU & Assembler

## Overview

This project implements a simplified ARM16 CPU in Verilog, together with a Python assembler for the lab’s custom ISA subset.  
The design follows the **lab-5.pdf** specification.

---

## Directory Structure

- `arm/` Verilog CPU design and testbenches
- `asm/` Python assembler for ARM16
- `netlist.pdf` CPU datapath/netlist diagram

---

## Features

### Assembler

- Supports all required instructions from lab spec’s ISA subset.
- Expands `BL` into `MOV x6, x7` + `B label` and auto-inserts return macros.
- Enforces `.global _main` directive.
- Forbids direct writes to PC except via branch instructions.
- Resolves labels to correct addresses.

### CPU (Verilog)

- Implements all arithmetic, logic, compare, branch, load, and store operations from the ISA subset.
- Uses separate instruction and data paths as specified.
- Includes module-level testbenches for simulation.
