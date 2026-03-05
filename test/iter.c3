module functionaltest;

import functional;
import functional::iter;
import std::io;

alias IterInt = Iter{int};
alias ApplyCallbackInt  = ApplyCallback {int};
alias ApplyCallbackBool = ApplyConditionalCallback {int};

fn bool check_filter(IterInt prev,IterInt now,ApplyCallbackBool  f) @inline 
{
    foreach( i : prev){
		foreach( i2 : now){
			if (f(i2)==false&&f(i)==false){
				return false;
			}
		}
    }
    return true;
}

fn bool check_transformation(IterInt prev,IterInt now,ApplyCallbackInt  f) @inline
{
    foreach( i : prev){
		foreach( i2 : now){
			if (f(i)!=i2){
				return false;
			}
		}
    }
    return true;
}

fn bool check_iter_transformations(IterInt prev,IterInt now,ApplyCallbackInt[] fs) @inline
{
    foreach( f : fs){
		if(check_transformation(prev,now,f)){
			return false;
		}
    }
    return true;
}

fn bool check_clone(IterInt prev,IterInt now) @inline
{
    for(usz i =0;i<prev.len;++i){
		int n = prev[i];
		int n2 = now[i];
		if (n2!=n) return false;
    }
    return true;
}

fn bool check_reverse(IterInt prev,IterInt now) @inline
{
    for(usz i = 0;i<prev.len;++i){
		int n = prev[(prev.len-i)-1];
		int n2 = now[i];
		if (n2!=n) return false;
    }
    return true;
}

fn void check_iter_implementation() @test
{
    IterInt iter = {1, 2, 3, 4};
    IterInt clone1 = iter.clone();
    test::@check(check_clone(iter,clone1),"clone I failed");

    IterInt reverse1 = iter.clone();
    reverse1.reverse();
    test::@check(check_reverse(iter,reverse1),"reverse I failed");

    IterInt trans1 = iter.clone();

    trans1
		.for_each(fn(x) => x*2)
		.for_each(fn(x) => x*4);

    test::@check(check_iter_transformations(iter,trans1, {
		fn(x) => x*2,
		fn(x) => x*4
    }),"transformation I failed");

    test::@check(trans1.contains(fn(i) => i < 10),"number must be less than 10");

    test::@check(trans1.contains(fn(i) => i == 32),"number must be equal to 32");

    test::@check(trans1.contains(fn(i) => i == 8),"number must be equal to 8");

    usz? idx8 = trans1.find(fn(num) => num == 8);
    if (catch errfind = idx8){
	test::@check(false,"Error Finding index of 8: %s",errfind);
    }

    test::@check(@ok(idx8==0),"index not match the predicate");

    IterInt trans2 = iter
	    .map(fn(x) => x*2,tmem)
	    .for_each(fn(x) => x*4);

    test::@check(check_iter_transformations(iter,trans2, {
		fn(x) => x*2,
		fn(x) => x*4
    }),"transformation II failed");

    IterInt filter1 = trans2
	    .filter(fn(num) => num > 23, tmem);

    test::@check(check_filter(
		trans2,
		filter1,
		fn(num) => num > 23),
		"filter I failed");

    int prev_value = filter1[1];
    filter1[1] = 10;
    test::@check(filter1[1]!=prev_value,"move of value in filter1 failed");
}
