from collections import deque


class MyCache:
    def __init__(
        self, l1_size, l2_size, l3_size, l1_latency, l2_latency, l3_latency, m_latency
    ):
        # All parameters are int.
        # *_size:    the number of blocks that can be stored
        #            in that level of cache
        # *_latency: the time it takes to access info from that level of cache
        #
        # assume copying 1 block from L3 to L2 takes l2_latency + l3_latency time;
        # assume copying 1 block from L1 from main memory takes l1_latency +
        #        l2_latency + l3_latency + m_latency time.
        self.l1 = deque(maxlen=l1_size)
        self.l2 = deque(maxlen=l2_size)
        self.l3 = deque(maxlen=l3_size)
        self.l1_late = l1_latency
        self.l2_late = l2_latency
        self.l3_late = l3_latency
        self.m_late = m_latency
        return

    def access(self, adds):
        # adds: list of int; each int is a memory address number
        hit_rate = 0
        # hit_rate should be the total_number_of_hits in l1/ len(adds)
        total_time = 0
        # total_time is the total amount of time it takes for all addresses in adds to be accessed

        # -----write your programme from here-----
        hits = 0

        for addr in adds:
            print("Addr: ", addr)
            if addr in self.l1:
                print("L1 hit")
                hits += 1
                total_time += self.l1_late

            elif addr in self.l2:
                print("L1 miss")
                print("L2 hit")

                total_time += self.l1_late + self.l2_late

            elif addr in self.l3:
                print("L1 miss")
                print("L2 miss")
                print("L3 hit")

                total_time += self.l1_late + self.l2_late + self.l3_late

            else:
                print("L1 miss")
                print("L2 miss")
                print("L3 miss")

                total_time += self.l1_late + self.l2_late + self.l3_late + self.m_late

        hit_rate = hits / len(adds)

        # -----do not change the output-----
        return total_time, hit_rate
