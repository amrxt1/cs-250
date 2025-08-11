# Assembler_arm16

An assembler written to convert assembly source code into binary files. Refer
to `lab-spec.pdf` for more information.

## Instructions Supported

|     | Instruction                 | Syntax                      |
| --- | --------------------------- | --------------------------- |
| \_  | Special Shifting            | `MOV <Rd>, <Rm>`            |
| \_  | Addition                    | `ADDS <Rd>, <Rn>, <Rm>`     |
| \_  | Subtraction                 | `SUBS <Rd>, <Rn>, <Rm>`     |
| \_  | Addition (Imm3)             | `ADDS <Rd>, <Rn>, #<imm3>`  |
| \_  | Subtraction (Imm3)          | `SUBS <Rd>, <Rn>, #<imm3>`  |
| \_  | Move                        | `MOV <Rd>, #<Imm8>`         |
| \_  | Compare Immediate           | `CMP <Rn>, #<imm8>`         |
| \_  | Addition (Imm8)             | `ADDS <Rdn>, #<imm8>`       |
| \_  | Subtraction (Imm8)          | `SUBS <Rdn>, #<imm8>`       |
| \_  | Bitwise AND                 | `ANDS <Rdn>, <Rm>`          |
| \_  | Bitwise Exclusive OR        | `EORS <Rdn>, <Rm>`          |
| \_  | Compare Registers           | `CMP <Rn>, <Rm>`            |
| \_  | Bitwise OR                  | `ORRS <Rdn>, <Rm>`          |
| \_  | Bitwise NOT                 | `MVNS <Rd>, <Rm>`           |
| \_  | Compute PC Relative Address | `LDR <Rt>, #<Imm8>`         |
| \_  | Store Register              | `STR <Rt>, [<Rn>, <Rm>]`    |
| \_  | Load Register               | `LDR <Rt>, [<Rn>, <Rm>]`    |
| \_  | Store Register (Immediate)  | `STR <Rt>, [<Rn>, #<imm5>]` |
| \_  | Load Register (Immediate)   | `LDR <Rt>, [<Rn>, #<imm5>]` |
| \_  | Conditional Branch          | `B.cond <label> (<#imm8>)`  |
| \_  | Unconditional Branch        | `B <label> (<#imm11>)`      |

## Usage

To assemble ARM16 assembly source files into binary output, run the assembler script as follows:

```bash
python3 asm_arm16.py SRC_CODE [-o OUT_FILE]
```

- `SRC_CODE` is the path to your assembly source file (e.g., program.asm).

- Optionally, specify `-o OUT_FILE` to set the output binary file name. If omitted, a default output filename will be used.

For further clarifications, refer to `/lab-spec.pdf`

## Implementing BL (Branch with Link)

`lab-spec.pdf` Section 6.3 says:

> 6.3 Function Calls
> Your users may decide to declare functions and use B/BL to call these functions. You will need to support this.
> Your assembler should make sure B/BL is the only way for the programmer to change PC’s value, so you
> should prevent PC from being changed by other instructions, including by the programmer using MOV.
> Your assembler should also implement BL. For our ARM16, this is done by:
>
> 1.  Saving current PC to R6 (LR: Link Register) using MOV
> 2.  Use B to branch to target function, after its finished execution,
> 3.  Use MOV to go back to original PC stored in R6 (e.g. main function) You are not required to support recursive function calls, you can assume only in \_main will other functions be called. Notice also that users may decide to use Symbols/Labels for their functions, so your assembler will need to figure out the appropriate memory addresses for these functions’ instructions in the main memory.

However, for the following:

```asm
.global _main
_main:
    // example addition: 1 + 2
	mov r0, #1
	mov r1, #2
    // bl add_fn would translate to the following
	mov r6, r7
	b add_fn

add_fn:
	add r0, r1, r0
	mov r7, r6
foo:
	mov r0, #111
bar:
	mov r1, #222
	mov r7, r6

exit:
	mov r0, #0
```

The above approach is in accordance with `Section 6.3`. However, if `mov pc, lr` is explicitly added by the assembler everytime, it would cause any function call to go back to the link register. For example, if we did:

```asm
...
    bl bar // lr store address to next istr, i.e., b add_fn
    b add_fn // after programme comes back here, and executes add_fn, it moves lr into pc which comes back here resulting in an infinite loop.
...
```

Conversely, if `mov pc, lr` is omitted, any branch to `add_fn` would step into `foo`.

### Therefore, the following must be kept in mind when using this assembler:

- The assembler supports either `BL` or `B` for a given label, but not both. Mixing them on the same label may cause _**unexpected behavior**_.
- Labels that are function entry points must only be called via `BL`. The assembler will automatically append a `mov pc, lr` instruction at these labels to implement the return.
- Labels used as jump targets for `B` or `B.cond` must not have return instructions `mov pc, lr`. Doing so is not permitted by the `lab-spec`.
- According to the lab specification, programmers must not manually alter the PC register except via branch or branch-with-link instructions (`B`, `BL`, etc.).
- Jumping `B` to a function label expecting to return will result in undefined or infinite looping behavior because the return address in `LR` may be invalid.
- Functions must always be entered via `BL` to ensure proper saving of the return address.
