module functionaltest;

import functional;
import functional::iter;
import std::io;

alias IterInt = Iter{int};
alias ApplyCallbackInt  = ApplyCallback{int};
alias ApplyCallbackBool = ApplyConditionalCallback{int};


fn bool check_filter(IterInt prev, IterInt now, ApplyCallbackBool f) @inline
{
    foreach (i : prev) {
        foreach (i2 : now) {
            if (f(i2) == false && f(i) == false) return false;
        }
    }
    return true;
}

fn bool check_transformation(IterInt prev, IterInt now, ApplyCallbackInt f) @inline
{
    foreach (i : prev) {
        foreach (i2 : now) {
            if (f(i) != i2) return false;
        }
    }
    return true;
}

fn bool check_iter_transformations(IterInt prev, IterInt now, ApplyCallbackInt[] fs) @inline
{
    foreach (f : fs) {
        if (check_transformation(prev, now, f)) return false;
    }
    return true;
}

fn bool check_clone(IterInt prev, IterInt now) @inline
{
    for (usz i = 0; i < prev.len; ++i) {
        if (now[i] != prev[i]) return false;
    }
    return true;
}

fn bool check_reverse(IterInt prev, IterInt now) @inline
{
    for (usz i = 0; i < prev.len; ++i) {
        if (now[i] != prev[(prev.len - i) - 1]) return false;
    }
    return true;
}


fn void test_clone() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt clone = iter.clone();
    test::@check(check_clone(iter, clone), "clone failed");
}

fn void test_reverse() @test
{
    IterInt iter    = {1, 2, 3, 4};
    IterInt rev     = iter.clone();
    rev.reverse();
    test::@check(check_reverse(iter, rev), "reverse failed");
}

fn void test_for_each_transformations() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter.clone();
    trans
        .for_each(fn(x) => x * 2)
        .for_each(fn(x) => x * 4);

    test::@check(
        check_iter_transformations(iter, trans, {
            fn(x) => x * 2,
            fn(x) => x * 4,
        }),
        "for_each chained transformations failed"
    );
}

fn void test_contains() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter.clone();
    trans
        .for_each(fn(x) => x * 2)
        .for_each(fn(x) => x * 4);

    test::@check(trans.contains(fn(i) => i < 10),  "expected a value less than 10");
    test::@check(trans.contains(fn(i) => i == 32), "expected value 32 to be present");
    test::@check(trans.contains(fn(i) => i == 8),  "expected value 8 to be present");
}

fn void test_find() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter.clone();
    trans
        .for_each(fn(x) => x * 2)
        .for_each(fn(x) => x * 4);

    usz? idx8 = trans.find(fn(num) => num == 8);
    if (catch err = idx8) {
        test::@check(false, "error finding index of 8: %s", err);
        return;
    }
    test::@check(idx8 == 0, "index of 8 does not match expected position 0");
}

fn void test_map_transformations() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter
        .map(fn(x) => x * 2, tmem)
        .for_each(fn(x) => x * 4);

    test::@check(
        check_iter_transformations(iter, trans, {
            fn(x) => x * 2,
            fn(x) => x * 4,
        }),
        "map + for_each transformations failed"
    );
}

fn void test_filter() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter
        .map(fn(x) => x * 2, tmem)
        .for_each(fn(x) => x * 4);

    IterInt filtered = trans.filter(fn(num) => num > 23, tmem);

    test::@check(
        check_filter(trans, filtered, fn(num) => num > 23),
        "filter failed: result contains values not satisfying predicate"
    );
}

fn void test_index_assignment() @test
{
    IterInt iter  = {1, 2, 3, 4};
    IterInt trans = iter
        .map(fn(x) => x * 2, tmem)
        .for_each(fn(x) => x * 4);

    IterInt filtered  = trans.filter(fn(num) => num > 23, tmem);
    int     prev_val  = filtered[1];
    filtered[1]       = 10;

    test::@check(filtered[1] != prev_val, "index assignment to filtered iter failed");
}