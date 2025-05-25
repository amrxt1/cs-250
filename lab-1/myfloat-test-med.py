from myfloat import MyFloat

ty = MyFloat(e=5, m=10)   # bias=15, total bits=16
tol = 1e-6

def test(desc, func, args, expected_bits_or_value):
    try:
        result = func(*args)
        # allow comparing either bit‐strings or floats
        if isinstance(expected_bits_or_value, str):
            ok = (result == expected_bits_or_value)
        else:  # float
            ok = abs(result - expected_bits_or_value) < tol
        print(f"{desc}: " + ('PASS ' if ok else 'FAIL ') + (f"got {result!r} expected: {expected_bits_or_value}"))
    except Exception as e:
        print(f"{desc}: CRASHED — {e}")

# toDec tests
test("1: toDec 5.25", ty.toDec, ["0100010101000000"], 5.25)
test("2: toDec −5.25", ty.toDec, ["1100010101000000"], -5.25)
test("3: toDec max normal", ty.toDec, ["0111101111111111"],
     (1 + (2**10 - 1)/1024) * 2**15)
test("4: toDec min normal", ty.toDec, ["0000010000000000"], 2**(-14))

# add tests
test("5:  5.25 + (−5.25) → 0", ty.add,
     ["0100010101000000", "1100010101000000"], "0000000000000000")

# 1.5 = 0|01111|1000000000
# 2.25 = 0|10000|0100000000
# 1.5+2.25=3.75→ 0|10000|1110000000
test("6:  1.5 + 2.25 → 3.75", ty.add,
     ["0011111000000000", "0100000100000000"],
     "0100001110000000")

# −1.5 and −2.25 same patterns with sign=1 → result −3.75
test("7: −1.5 + (−2.25) → −3.75", ty.add,
     ["1011111000000000", "1100000100000000"],
     "1100001110000000")

# 10.0 +  6.0 → 16.0 (already correct)
test("8: 10.0 + 6.0 → 16.0", ty.add,
     ["0100100100000000", "0100011000000000"],
     "0100110000000000")

# 8.0 = 0|10010|0000000000
# 0.5 = 0|01111|1000000000
# 8.0 + 0.5 = 8.5 → 0|10010|0001000000
test("9:  8.0 + 0.5 → 8.5", ty.add,
     ["0100100000000000", "0011111000000000"],
     "0100100001000000")

# Rounding‐truncation example:
# (1.9990234375*4)×2 = 15.9921875 → ideal mantissa 1111111111
# but chopping guard bit → …1111111110
test("10: rounding/truncation", ty.add,
     ["0100011111111111", "0100011111111111"],
     "0100101111111110")

print("Done.")
