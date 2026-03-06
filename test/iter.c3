module iter_test;

import functional::iter;
import std::io;


// ======================================
// ============= TEST CLONE =============
// ======================================

fn void clone() @test
{
    Iter{int} iter  = {1, 2, 3, 4};
    Iter{int} clone = iter.clone();

    for (usz i = 0; i < iter.len; ++i) {
        assert(iter[i] == clone[i], "clone failed");
    }
}

// ========================================
// ============= TEST REVERSE =============
// ========================================

fn void reverse() @test
{
    Iter{int} iter    = {1, 2, 3, 4};
    Iter{int} rev     = iter.clone().reverse();

    for (usz i = 0; i < iter.len; ++i) {
        assert(rev[i] == iter[(iter.len - i) - 1], "reverse failed");
    }
}

// ===============================================
// ============= TEST TRANSFORMATION =============
// ===============================================

fn void for_each_transformations() @test
{
    Iter{int} iter  = {1, 2, 3, 4};
    Iter{int} trans = iter.clone()
        .for_each(fn(x) => x * 2)
        .for_each(fn(x) => x * 4);

    assert(iter.len == trans.len, "for_each: length mismatch after transformation");
    for (usz i = 0; i < iter.len; i++) {
        int expected = iter[i] * 2 * 4;
        assert(trans[i] == expected, "for_each chained transformation failed at index %d", i);
    }
}

// =========================================
// ============= TEST CONTAINS =============
// =========================================

fn void contains() @test
{
    Iter{int} iter  = {1, 2, 3, 4};
    iter
        .for_each(fn(x) => x * 2)
        .for_each(fn(x) => x * 4);

    assert(iter.contains(fn(i) => i < 10),  "expected a value less than 10");
    assert(iter.contains(fn(i) => i == 32), "expected value 32 to be present");
    assert(!iter.contains(fn(i) => i == 7),  "expected value 7 to not be present");
}

// =====================================
// ============= TEST FIND =============
// =====================================

fn void find() @test
{
    Iter{int} iter = {1, 2, 3, 4};

    usz? idx1 = iter.find(fn(num) => num == 8);
    if (catch err = idx1) {
        assert(err == iter::INDEX_NOT_FOUND, "error finding index of 8: %s");
    }

    usz? idx2 = iter.find(fn(num) => num == 3);
    if (catch err = idx2) {
        assert(false, "error finding num");
    }
    assert(idx2 == 2, "expexted value equals to 2");
}

// ====================================
// ============= TEST MAP =============
// ====================================

fn void map_transformations() @test
{
    Iter{int} iter  = {1, 2, 3, 4};
    Iter{int} trans = iter
        .map(fn(x) => x * 2, tmem);

    assert(iter.len == trans.len, "map: length mismatch after transformation");
    for (usz i = 0; i < iter.len; i++) {
        int expected = iter[i] * 2;
        assert(trans[i] == expected, "map + for_each transformation failed at index %d", i);
    }
}


// =======================================
// ============= TEST FILTER =============
// =======================================

fn void filter() @test
{
    Iter{int} iter  = {1, 2, 3, 4};

    Iter{int} filtered = iter
        .filter(fn(num) => num < 3, tmem);

    assert(filtered.len == 2, "expect filter size to equal 2");

    for (int i = 0; i < filtered.len; i++) {
        assert(filtered[i] == iter[i], "filtered array copied wrong");
    }
}