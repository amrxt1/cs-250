# Lab 4 - CSCI250

This directory contains the Verilog implementations for Lab 4 components.

## Directory Structure

### CMP/

- `CMP.v` - Compare module implementation with N, C, Z flags and 16 condition codes
- `CMP_tb.v` - Comprehensive testbench covering all condition codes
- `CMP_tb.bmp` - Simulation waveform output
- `CMP.pdf` - Synthesized design report

### DataBusController/

- `DataBusController.v` - Bidirectional data bus controller for ALU/register/memory interfacing
- `DataBusController_tb.v` - Testbench for data bus direction control
- `DataBusController_tb.bmp` - Simulation waveform output
- `DataBusController.pdf` - Synthesized design report

### MemoryController/

- `MemoryController.v` - Memory-to-databus controller with bidirectional support
- `MemoryController_tb.v` - Testbench for memory read/write operations
- `MemoryController_tb.bmp` - Simulation waveform output
- `MemoryController.pdf` - Synthesized design report

### RegArray/

- `RegArray.v` - 8-register array with multi-port read, PC auto-increment
- `RegArray_tb.v` - Testbench for register operations and PC behavior
- `RegArray-final_tb.bmp` - Simulation waveform output
- `RegArray.pdf` - Synthesized design report

## File Types

- `.v` files: Verilog module implementations
- `_tb.v` files: Testbenches for each module
- `.bmp` files: Simulation waveform screenshots
- `.pdf` files: Quartus synthesis reports
