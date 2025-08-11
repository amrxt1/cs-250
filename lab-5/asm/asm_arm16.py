import argparse
from pathlib import Path

"""
asm_arm16.py
Author: Amritveer Singh
Description: Assembler for ARM16 assembly language converting source code to binary.
Created: 2025-08-08
"""

RET = "MOV x7, x6"


def print_list_with_pc(arr):
    for i, line in enumerate(arr):
        print(i, line)


def remove_lines_and_comments(file):
    new_file = []
    hasGlobalMain = False
    for line in file:
        # remove ';' comments
        line = line.split(";")[0]
        # then remove '//' comments
        line = line.split("//")[0]
        # then strip whitespace
        line = line.strip()
        # keep the line if there's anything after removing comments and blank space
        if line:
            if line.startswith(".global") and "_main" in line:
                hasGlobalMain = True
                continue
            new_file.append(line)
    if not hasGlobalMain:
        raise ValueError("Error: could not find .global _main")

    # print("PASS0: Remove blanks and comments.")
    # print_list_with_pc(new_file)
    return new_file


def forbid_pc_writes(lines):
    writes_first = {
        "MOV",
        "MOVS",
        "ADDS",
        "SUBS",
        "ANDS",
        "EORS",
        "ORRS",
        "MVNS",
        # CMP not included; it writes flags only.
    }

    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if not s or s.endswith(":"):  # label or blank
            continue

        parts = s.split(None, 1)  # [opcode, operands?(hopefully)]
        op = parts[0].upper()

        # Branches are allowed to change PC
        if op == "B" or op == "BL" or op.startswith("B."):
            continue

        ops = []
        if len(parts) > 1:
            for p in parts[1].split(","):
                p = p.strip()
                if p:
                    ops.append(p)

        # no operands, nothing to do
        if not ops:
            continue

        first = ops[0].rstrip(",").lower()  # destination op
        is_r7 = (
            len(first) >= 2  # make sure its 2 letters or more
            and first[0] in ("x", "r")  # first letter is x or r, accepted reg format
            and first[1:].isdigit()
            and int(first[1:]) == 7
        )

        # ops that write their first operand
        if op in writes_first and is_r7:
            raise ValueError(
                f"Illegal PC write at line {i}: '{raw}'. Only B/BL may change PC (x7)."
            )

        # loads write Rt (first operand)
        if op == "LDR" and is_r7:
            raise ValueError(
                f"Illegal PC write via LDR at line {i}: '{raw}'. Only B/BL may change PC (x7)."
            )

    return lines


def expand_bl(file):
    # print("\nPASS1: expand BL")

    required_symbols = set()
    expanded_file = []

    for line in file:
        if line.startswith("BL"):
            label = line.split()[1]
            # Branch Link
            # save PC to LR
            expanded_file.append("MOV x6, x7")
            # add B to func
            expanded_file.append(f"B {label}")
            # add to required_symbols, symbols to add RET at EOF
            required_symbols.add(label)
        else:
            expanded_file.append(line)

    # print_list_with_pc(expanded_file)
    # print(required_symbols)

    return expanded_file, required_symbols


def add_ret(file, symbols):
    # print("\nPASS2: Add RET where required")

    expanded_file = []

    inLabelFlag = file[0].endswith(":") and file[0][:-1] in symbols

    for line in file:
        # enetering is also exiting
        if inLabelFlag and line.endswith(":"):
            # move lr into pc and return to OG control flow
            expanded_file.append(RET)
            expanded_file.append(line)
            # set flag low and check again below
            inLabelFlag = False
        else:
            expanded_file.append(line)

        if line.endswith(":") and line[:-1] in symbols:
            # setting the flag when entering
            inLabelFlag = True

    # on exit, if flag is high, append another RET
    if inLabelFlag:
        expanded_file.append(RET)

    # print_list_with_pc(expanded_file)
    # print("Symblos: ", symbols)

    return expanded_file


def calc_asm(file, symbols):
    # print("\nPASS3: calculate symbols dict, required memory addresses, remove labels")

    pc = 0
    reduced_file = []
    symbols_dict = {}
    for line in file:
        if line.endswith(":"):
            # is a label
            symbols_dict[line[:-1]] = pc
            # skip labels in asm
            continue
        else:
            pc += 1
            reduced_file.append(line)

    # print_list_with_pc(reduced_file)
    # print(symbols_dict)

    if "_main" not in symbols_dict:
        raise ValueError("Error: declared .global _main but no _main: label found")

    return reduced_file, symbols_dict


def link_labels(file, addr_map):
    # print("\nPASS4: Link function addresses to labels")

    linked_file = []
    for line in file:
        line_parts = line.split()

        # B <label>
        if line_parts[0] == "B" and not line_parts[1].startswith("#"):
            linked_file.append(f"B #{addr_map[line_parts[1]]}")
            continue
        # B.cond <label>
        if (
            line_parts[0].startswith("B.")
            and len(line_parts) == 2
            and not line_parts[1].startswith("#")
        ):
            linked_file.append(f"{line_parts[0]} #{addr_map[line_parts[1]]}")
            continue

        linked_file.append(line)

    # print_list_with_pc(linked_file)
    # print(addr_map)

    return linked_file


def valid_reg(r):
    t = r.strip().rstrip(",").lower()
    if t.startswith(("r", "x")) and t[1:].isdigit():
        n = int(t[1:])
        return 0 <= n <= 7
    return False


# check validity of reg
def reg3(tok):
    t = tok.strip().rstrip(",").lower()
    if not (t.startswith(("x", "r")) and t[1:].isdigit()):
        raise ValueError("bad register: " + tok)
    n = int(t[1:])
    if n < 0 or n > 7:
        raise ValueError("register out of range (0..7): " + tok)
    return n


def imm_u(tok):
    s = tok.strip()
    if s.startswith("#"):  # base-10
        s = s[1:]
    if s.lower().startswith("0x"):  # hex
        return int(s, 16)
    return int(s, 10)


def fit(v, bits, instr):
    if v < 0 or v >= (1 << bits):
        raise ValueError(f"{instr} must fit in {bits} bits (got {v})")
    return v


# cond LUT
COND = {
    "eq": 0b0000,  # Z == 1
    "ne": 0b0001,  # Z == 0
    "cs": 0b0010,  # C ==1
    "cc": 0b0011,  # C ==0
    "mi": 0b0100,  # N == 1
    "pl": 0b0101,  # N == 0
    "vs": 0b0110,  # V == 1
    "vc": 0b0111,  # V == 0
    "hi": 0b1000,  # C and not Z
    "ls": 0b1001,  # not C or Z
    "ge": 0b1010,  # (N and V) or (not N and not V)
    "lt": 0b1011,  # N xor V
    "gt": 0b1100,  # not Z and GE
    "le": 0b1101,  # Z or LT
    "al": 0b1110,  # Always
    "nv": 0b1111,  # Never
}

# op4 for 010000 group
LOGIC_OP4 = {
    "ANDS": 0b0000,
    "EORS": 0b0001,
    "CMP": 0b1010,
    "ORRS": 0b1100,
    "MVNS": 0b1111,
}


def assemble_bin(lines):
    # print("\nPASS5: Assemble asm into bin")
    words = []  # list of 16-bit binary strings

    for i, raw in enumerate(lines):
        line = raw.strip()
        if not line:
            continue

        # split instr
        parts = line.split(None, 1)
        op = parts[0].upper()
        ops = []
        if len(parts) > 1:
            for p in parts[1].split(","):
                p = p.strip()
                if p:
                    ops.append(p)
        # # print(op, ops)  # debug

        # MOV (register form): 0000000000 Rm Rd
        if op == "MOV" and len(ops) == 2 and ops[1][:1].lower() in "xr":
            rd = reg3(ops[0])
            rm = reg3(ops[1])
            rm_b = bin(fit(rm, 3, "reg3"))[2:].zfill(3)
            rd_b = bin(fit(rd, 3, "reg3"))[2:].zfill(3)
            words.append("0000000000" + rm_b + rd_b)
            continue

        # MOV (immediate) / MOVS: 00100 Rd Imm8
        # accept MOV or MOVS with imm8, but not register as second operand
        if op in ("MOV", "MOVS") and len(ops) == 2 and ops[1][:1].lower() not in "xr":
            rd = reg3(ops[0])
            imm = fit(imm_u(ops[1]), 8, "imm8")
            rd_b = bin(rd)[2:].zfill(3)
            imm_b = bin(imm)[2:].zfill(8)
            words.append("00100" + rd_b + imm_b)
            continue

        # ADDS / SUBS (register): 00011 md Rm Rn Rd
        if op in ("ADDS", "SUBS") and len(ops) == 3 and ops[2][:1].lower() in "xr":
            rd = reg3(ops[0])
            rn = reg3(ops[1])
            rm = reg3(ops[2])
            md = "00" if op == "ADDS" else "01"
            rm_b = bin(fit(rm, 3, "reg3"))[2:].zfill(3)
            rn_b = bin(fit(rn, 3, "reg3"))[2:].zfill(3)
            rd_b = bin(fit(rd, 3, "reg3"))[2:].zfill(3)
            words.append("00011" + md + rm_b + rn_b + rd_b)
            continue

        # ADDS / SUBS (imm3): 00011 md Imm3 Rn Rd
        if op in ("ADDS", "SUBS") and len(ops) == 3 and ops[2][:1].lower() not in "xr":
            rd = reg3(ops[0])
            rn = reg3(ops[1])
            imm3 = fit(imm_u(ops[2]), 3, "imm3")
            md = "10" if op == "ADDS" else "11"
            imm3_b = bin(imm3)[2:].zfill(3)
            rn_b = bin(fit(rn, 3, "reg3"))[2:].zfill(3)
            rd_b = bin(fit(rd, 3, "reg3"))[2:].zfill(3)
            words.append("00011" + md + imm3_b + rn_b + rd_b)
            continue

        # ADDS / SUBS (imm8 to Rdn): 00110/00111 Rdn Imm8
        if op in ("ADDS", "SUBS") and len(ops) == 2 and ops[1][:1].lower() not in "xr":
            rdn = reg3(ops[0])
            imm8 = fit(imm_u(ops[1]), 8, "imm8")
            rdn_b = bin(fit(rdn, 3, "reg3"))[2:].zfill(3)
            imm_b = bin(imm8)[2:].zfill(8)
            top = "00110" if op == "ADDS" else "00111"
            words.append(top + rdn_b + imm_b)
            continue

        # Logic group (register): 010000 op4 Rm Rdn
        # ANDS, EORS, CMP (reg), ORRS, MVNS
        if op in LOGIC_OP4 and len(ops) == 2 and ops[1][:1].lower() in "xr":
            rdn = reg3(ops[0])
            rm = reg3(ops[1])
            op4 = LOGIC_OP4[op]
            op4_b = bin(op4)[2:].zfill(4)
            rm_b = bin(fit(rm, 3, "reg3"))[2:].zfill(3)
            rdn_b = bin(fit(rdn, 3, "reg3"))[2:].zfill(3)
            words.append("010000" + op4_b + rm_b + rdn_b)
            continue

        # CMP (imm8): 00101 Rn Imm8
        if op == "CMP" and len(ops) == 2 and ops[1][:1].lower() not in "xr":
            rn = reg3(ops[0])
            imm = fit(imm_u(ops[1]), 8, "imm8")
            rn_b = bin(fit(rn, 3, "reg3"))[2:].zfill(3)
            imm_b = bin(imm)[2:].zfill(8)
            words.append("00101" + rn_b + imm_b)
            continue

        # LDR (PC-relative): 01001 Rt Imm8
        if op == "LDR" and len(ops) == 2 and ops[1][:1].lower() not in "xr":
            rt = reg3(ops[0])
            imm8 = fit(imm_u(ops[1]), 8, "imm8")
            rt_b = bin(fit(rt, 3, "reg3"))[2:].zfill(3)
            imm_b = bin(imm8)[2:].zfill(8)
            words.append("01001" + rt_b + imm_b)
            continue

        # STR/LDR (register offset): 0101 opB Rm Rn Rt
        # STR opB=000, LDR opB=100
        if op in ("STR", "LDR") and len(ops) == 2 and ops[1].strip().startswith("["):
            inner = ops[1].strip()
            if not inner.endswith("]"):
                raise ValueError(f"bad address syntax at line {i}: {ops[1]}")
            inner = inner[1:-1]  # drop [ ]
            parts2 = []
            for q in inner.split(","):
                q = q.strip()
                if q:
                    parts2.append(q)
            if len(parts2) == 2 and parts2[1][:1].lower() in "xr":
                # register offset form
                rt = reg3(ops[0])
                rn = reg3(parts2[0])
                rm = reg3(parts2[1])
                opb = "100" if op == "LDR" else "000"
                rm_b = bin(fit(rm, 3, "reg3"))[2:].zfill(3)
                rn_b = bin(fit(rn, 3, "reg3"))[2:].zfill(3)
                rt_b = bin(fit(rt, 3, "reg3"))[2:].zfill(3)
                words.append("0101" + opb + rm_b + rn_b + rt_b)
                continue
            # fall through to imm5 handling below (if second thing isn’t a reg)

        # STR/LDR (imm5 offset): 0110 Op Imm5 Rn Rt   (Op=0 store, 1 load)
        # expects "[Rn, #imm5]"
        if op in ("STR", "LDR") and len(ops) == 2 and ops[1].strip().startswith("["):
            inner = ops[1].strip()
            if not inner.endswith("]"):
                raise ValueError(f"bad address syntax at line {i}: {ops[1]}")
            inner = inner[1:-1]
            parts2 = []
            for q in inner.split(","):
                q = q.strip()
                if q:
                    parts2.append(q)
            if len(parts2) == 2 and parts2[1][:1].lower() not in "xr":
                rt = reg3(ops[0])
                rn = reg3(parts2[0])
                imm5 = fit(imm_u(parts2[1]), 5, "imm5")
                opb1 = "1" if op == "LDR" else "0"
                imm5_b = bin(imm5)[2:].zfill(5)
                rn_b = bin(fit(rn, 3, "reg3"))[2:].zfill(3)
                rt_b = bin(fit(rt, 3, "reg3"))[2:].zfill(3)
                words.append("0110" + opb1 + imm5_b + rn_b + rt_b)
                continue

        # B.cond #imm8: 1101 cond Imm8
        if op.startswith("B.") and len(ops) == 1:
            cond = op.split(".", 1)[1].lower()
            if cond not in COND:
                raise ValueError(f"unknown condition: {cond}")
            imm = fit(imm_u(ops[0]), 8, "imm8")
            cond_b = bin(COND[cond])[2:].zfill(4)
            imm_b = bin(imm)[2:].zfill(8)
            words.append("1101" + cond_b + imm_b)
            continue

        # B #imm11: 11100 Imm11
        if op == "B" and len(ops) == 1:
            imm = fit(imm_u(ops[0]), 11, "imm11")
            imm_b = bin(imm)[2:].zfill(11)
            words.append("11100" + imm_b)
            continue

        # not matched
        raise ValueError(f"unsupported instruction {i}: '{raw}'")

    # show 16-bit binaries
    # for pc, b in enumerate(words):
    # print(f"{pc:3d} {b}")
    return words


def main():
    # print("\n\tarm16 ASSEMBLER\n")
    ap = argparse.ArgumentParser()
    ap.add_argument("src", help="assembly source file")
    ap.add_argument(
        "-o", "--out", default="a.out", help="output file (raw 16-bit words)"
    )
    args = ap.parse_args()

    with open(args.src, "r") as f:
        src_lines = [line.rstrip("\n") for line in f]

    # step 0: remove all blank lines and comments
    # also check for global main directive
    pass0 = remove_lines_and_comments(src_lines)
    #
    # maybe check for b and bl using same label
    #
    # check if PC being written to
    forbid_pc_writes(pass0)
    # (expand BL into MOV and B) && (collect symbols which need to be Branch-Linked)
    pass1, symbols = expand_bl(pass0)
    # add RET statements where required
    pass2 = add_ret(pass1, symbols)
    # calculate symbols dict, required memory addresses, remove labels
    pass3, symbols_addr_map = calc_asm(pass2, symbols)
    # use symbol dict to replace labels where rquired
    pass4 = link_labels(pass3, symbols_addr_map)
    # convert pure sequential asm into bin
    pass5 = assemble_bin(pass4)

    # old implementation:
    # step 1: calculate symbol addresses and make a symbols dict
    # symbols = determine_symbols(pass1)
    # step 2: expand BL
    # expanded_file = expand_bl(new_file)
    # # print(expanded_file)
    # step 3: parse into binary

    words = pass5

    with open(args.out, "w") as f:
        for w in words:
            f.write(f"{w}\n")


if __name__ == "__main__":
    main()
