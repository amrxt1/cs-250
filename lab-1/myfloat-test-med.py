from myfloat import MyFloat

ty = MyFloat(e=5, m=10)  # 5-bit exponent, 10-bit mantissa

def test(desc, func, args, expected):
    try:
        result = func(*args)
        if result == expected or (isinstance(result, float) and abs(result - expected) < 1e-6):
            print(f"{desc}: PASS")
        else:
            print(f"{desc}: FAIL — expected {expected}, got {result}")
    except Exception as e:
        print(f"{desc}: CRASHED — {e}")

# Only normalized numbers. So exponent != 0 or 31 (if bias=15)

# Normal number tests for toDec
test("Test 1: Simple positive number", ty.toDec, ["0100010101000000"], 5.25)
test("Test 2: Simple negative number", ty.toDec, ["1100010101000000"], -5.25)
test("Test 3: Largest normal (before overflow)", ty.toDec, ["0111101111111111"], (1 + (2**10 - 1)/1024) * 2**15)
test("Test 4: Smallest normal (after underflow cutoff)", ty.toDec, ["0000010000000000"], 1.0 * 2**(-14))

# add() with normalized inputs
test("Test 5: Add 5.25 and -5.25", ty.add, ["0100010101000000", "1100010101000000"], "0000000000000000")
test("Test 6: Add 1.5 + 2.25", ty.add, ["0100001000000000", "0100010010000000"], "0100011010000000")  # 3.75
test("Test 7: Add -1.5 + -2.25", ty.add, ["1100001000000000", "1100010010000000"], "1100011010000000")
test("Test 8: Add 10.0 + 6.0", ty.add, ["0100100100000000", "0100011000000000"], "0100110000000000")  # 16.0
test("Test 9: Add numbers with different exponents", ty.add, ["0100100000000000", "0011110000000000"], "0100100010000000")  # 8.0 + 0.5 = 8.5
test("Test 10: Add values causing rounding", ty.add, ["0100011111111111", "0100011111111111"], "0100101111111110")  # Close to 31.998
