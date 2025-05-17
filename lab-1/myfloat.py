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

        return result


if __name__ == "__main__":
    print("local test mode")
    # write your own test code here
