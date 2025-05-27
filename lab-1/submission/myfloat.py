#
#   Original: Jetic Gu
#   Columbia College
#   2024-09-13
#


class MyFloat:
    def __init__(self, m, e):
        # e is an int, representing the number of bits for the exponent
        self.e = e
        # m is an int, representing the number of bits for the mantissa
        self.m = m
        return

    def toDec(self, binstring):
        """
        This method converts binstring
         It converts binstring to a normal python float, then returns it
        """
        if not isinstance(binstring, str):
            raise TypeError("Wrong datatype, expecting str")
        if len(binstring) != 1 + self.m + self.e:
            raise ValueError("Length of binary number incorrect")
            # the first bit is alwasy the sign bit, followed by exponent, then mantissa
        for i in binstring:
            if i != "0" and i != "1":
                raise ValueError("Expecting 0s and 1s only")

        result = 0
        # complete the method from here:
        e_str, m_str = binstring[1 : self.e + 1], binstring[self.e + 1 :]
        exp, man = 0, 0
        bias = (2 ** (self.e - 1)) - 1
        for idx, x in enumerate(reversed(list(e_str))):
            exp = exp + int(x) * (2**idx)
        for idx, x in enumerate(list(m_str)):
            man = man + int(x) * (1 / (2 ** (idx + 1)))
        result = (1 + man) * (2 ** (exp - bias)) * ((-1) ** int(binstring[0]))  #
        return result

    def add(self, x, y):
        """
        This method adds the two number up, then outputs the result
        """
        result = ""
        # complete the method from here:

        # deconstruct string to sign, mantissa, exponent
        sign_x, e_x_str, man_x = x[0], x[1 : self.e + 1], "1" + x[self.e + 1 :]
        sign_y, e_y_str, man_y = y[0], y[1 : self.e + 1], "1" + y[self.e + 1 :]

        result_man = ""
        result_exp = ""
        result_sign = ""

        # assuming lenX equal lenY, we convert both exponents to Dec
        exp_x, exp_y = 0, 0
        for i in range(0, len(e_x_str)):
            exp_x = exp_x + int(e_x_str[::-1][i]) * (2**i)
            exp_y = exp_y + int(e_y_str[::-1][i]) * (2**i)

        # calculating the difference in exponents
        exp_off = abs(exp_y - exp_x)

        # prepend the smaller exponent mantissa with suitable number of 0s
        if exp_x < exp_y:
            man_x = ("0" * (exp_off) + man_x)[: self.m + 1]  # normalizes the Mantissas
            result_exp = exp_y
        elif exp_y <= exp_x:
            man_y = ("0" * (exp_off) + man_y)[: self.m + 1]
            result_exp = exp_x

        # compare the binstrings' signs to decide whether to add them or subtract
        if int(sign_x) ^ int(sign_y):
            # lets first check for the bigger mantissa
            bigger_number_is_x = False
            for i in range(0, len(man_y)):
                if man_y[i] != man_x[i]:
                    bigger_number_is_x = int(man_x[i]) >= int(man_y[i])
                    break

            if bigger_number_is_x:
                result_sign, man_a, man_b = sign_x, man_x, man_y
            else:
                result_sign, man_a, man_b = sign_y, man_y, man_x

            # implement subtraction
            borrow = False
            result_man = ""
            for i in range(len(man_y) - 1, -1, -1):
                bit_a = bool(int(man_a[i]))
                bit_b = bool(int(man_b[i]))

                result_man = ("1" if (bit_a ^ (bit_b ^ borrow)) else "0") + result_man
                borrow = (not bit_a and bit_b) or (not (bit_b ^ bit_a) and borrow)

            if result_man.find("1") == -1:
                return "0" * (self.m + self.e + 1)
            else:
                i = 0
                while True:
                    if result_man[i] == "0":
                        result_man = result_man[1:] + "0"
                        result_exp = result_exp - 1
                    else:
                        return result_sign + bin(result_exp)[2:] + result_man[1:]
        else:
            # print(f"\nLets do addition\n {x} + {y}")
            result_sign = sign_x
            # let's try adding these now
            carry = False
            result_man = ""
            for i in range(len(man_y) - 1, -1, -1):
                bit_x = bool(int(man_x[i]))
                bit_y = bool(int(man_y[i]))

                result_man = ("1" if ((bit_x ^ bit_y) ^ (carry)) else "0") + result_man
                carry = (bit_x and bit_y) or ((bit_x ^ bit_y) and carry)
                # print(f"Adding {man_x[i]} + {man_y[i]} = {result_man}   carry: {carry}")

            if carry:
                result_exp = result_exp + 1
                result_man = result_man[:-1]
                result = result_sign + bin(result_exp)[2:] + result_man
            else:
                result = result_sign + bin(result_exp)[2:] + result_man[1:]

        return result


if __name__ == "__main__":
    # write tests here
    print("Testing stuff")
