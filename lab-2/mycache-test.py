from mycache import MyCache

mc = MyCache(4, 8, 1024, 2, 8, 32, 128)

adds = [1, 2, 3, 4, 5, 6, 7, 8, 1, 1, 1, 2, 4, 6, 7, 8, 2, 1, 2]

total_time, hit_rate = mc.access(adds)
print("Total latency:", total_time)
print("L1 hit rate:", hit_rate)
