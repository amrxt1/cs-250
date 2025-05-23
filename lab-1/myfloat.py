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
        e_str = binstring[1:self.e+1]
        m_str = binstring[self.e+1:-1]
        exp=0
        man=0
        for idx, x in enumerate(reversed(list(e_str))):
            exp = exp +int(x)*(2**idx)
        for idx, x in enumerate(list(m_str)):
            man = man + int(x)*(1/(2**(idx+1)))
        result = (1+man)*(2**(exp-15))*((-1)**int(binstring[0]))
        return result


    def add(self, x, y):
        """
        This method adds the two number up, then outputs the result
        """
        result = ""
        # complete the method from here:

        # deconstruct string to sign, mantissa, exponent
        sign_x, man_x, e_x_str = x[0], "1"+x[self.e+1:], x[1:self.e+1][::-1]
        sign_y, man_y, e_y_str = y[0], "1"+y[self.e+1:], y[1:self.e+1][::-1]

        result_man = ""
        result_exp = ""
        result_sign = ""
        #assuming lenX equal lenY, we convert both exponents to Dec
        exp_x, exp_y = 0, 0
        for i in range(0, len(e_x_str)):
            exp_x = (exp_x + int(e_x_str[i])*(2**i))
            exp_y = (exp_y+ int(e_y_str[i])*(2**i))
            print(exp_x, exp_y)

        # calculating the difference in exponents
        exp_off = abs(exp_y - exp_x)
        print("Offset bw exponents:\t",exp_off)


        # prepend the smaller exponent mantissa with suitable number of 0s
        if exp_x<exp_y:
            man_x = ("0"*(exp_off) + man_x)[:self.m+1] # normalizes the Mantissas
        elif exp_y<exp_x:
            man_y = ("0"*(exp_off) + man_y)[:self.m+1]
        else:
            exp_off = 1
        print(f"Mantissas after: \nx: {man_x} \ny: {man_y}")


        # compare the binstrings' signs to decide whether to add them or subtract
        if int(sign_x) ^ int(sign_y):
            print("Lets do subtraction")
            # lets first check for the bigger mantissa

            bigger_number_is_x = -1

            for i in range( len(man_y)-1, -1, -1):
                if man_y[i]==man_x[i]:
                    continue
                if man_y[i]>man_x[i]:
                    bigger_number_is_x = False
                    break
                if man_y[i]<man_x[i]:
                    bigger_number_is_x = True
                    break

            if bigger_number_is_x==-1:
                man_a = man_x
                man_b = man_y
            elif bigger_number_is_x:
                man_a = man_x
                man_b = man_y
            else:
                man_a = man_y
                man_b = man_x
            # implement subtraction
            borrow = False
            result_man = ""
            for i in range(len(man_y) - 1, -1, -1):
                bit_a = bool(int(man_a[i]))
                bit_b = bool(int(man_b[i]))

                result_man = ("1" if ( bit_a ^ (bit_b ^ borrow) ) else "0") + result_man
                borrow = ( (not(bit_b ^ borrow)) and bit_a ) or ( (not bit_b) and borrow )
                print(bit_a, man_x[i]," - ", bit_b, man_y[i], " gives us ", result_man, "and borrow is : ", borrow)
        else:
            print("Lets do addition")
            # let's try adding these now
            carry = False
            result_man = ""
            for i in range(len(man_y) - 1, -1, -1):
                bit_x = bool(int(man_x[i]))
                bit_y = bool(int(man_y[i]))

                result_man = ("1" if ((bit_x ^ bit_y) ^ (carry)) else "0") + result_man
                carry = (bit_x and bit_y) ^ ((bit_x ^ bit_y) and carry )
                print(bit_x, man_x[i]," + ", bit_y, man_y[i], " gives us ", result_man, "and carry is : ", carry)





        return result


if __name__ == "__main__":
    print("local test mode")
    # write your own test code here
