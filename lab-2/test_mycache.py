# This test is AI-generated

import pytest
from collections import deque
from mycache import MyCache

L1_LAT, L2_LAT, L3_LAT, M_LAT = 1, 5, 20, 100


@pytest.fixture
def default_cache():
    return MyCache(2, 3, 4, L1_LAT, L2_LAT, L3_LAT, M_LAT)


def test_all_misses(default_cache):
    adds = [1, 2, 3]
    total, rate = default_cache.access(adds)
    assert total == (L1_LAT + L2_LAT + L3_LAT + M_LAT) * 3
    assert rate == 0.0


def test_all_l1_hits_after_fill(default_cache):
    default_cache.access([10, 20])
    total, rate = default_cache.access([10, 20, 10, 20])
    assert total == L1_LAT * 4
    assert rate == 1.0


def test_l2_hit_promotes_to_l1():
    c = MyCache(1, 2, 3, L1_LAT, L2_LAT, L3_LAT, M_LAT)
    c.access([1, 2])
    assert list(c.l1) == [2]
    assert c.l2 == deque([1, 2], maxlen=2)

    total, rate = c.access([1])
    assert total == L1_LAT + L2_LAT
    assert rate == 0.0
    assert list(c.l1) == [1]
    assert c.l2 == deque([1, 2], maxlen=2)


def test_l3_hit_promotes_to_l2_and_l1():
    c = MyCache(1, 1, 2, L1_LAT, L2_LAT, L3_LAT, M_LAT)
    c.access([100, 200])
    assert list(c.l1) == [200]
    assert list(c.l2) == [200]
    assert c.l3 == deque([100, 200], maxlen=2)

    total, rate = c.access([100])
    assert total == L1_LAT + L2_LAT + L3_LAT
    assert rate == 0.0
    assert list(c.l1) == [100]
    assert list(c.l2) == [100]


def test_mixed_access_pattern(default_cache):
    seq = [1, 2, 1, 3, 2, 4, 1]
    total, rate = default_cache.access(seq)
    assert total == 532  # computed miss/hit costs
    assert rate == pytest.approx(2 / 7)  # two L1 hits out of seven


def test_eviction_behavior_in_l3():
    c = MyCache(10, 10, 2, L1_LAT, L2_LAT, L3_LAT, M_LAT)
    c.access([5, 6])
    assert list(c.l3) == [5, 6]
    c.access([7])
    assert list(c.l3) == [6, 7]
    c.access([8])
    assert list(c.l3) == [7, 8]
