preserve
clear

// setup
set obs 100
qui gen n = _n
qui gen m = _n
qui gen x = round(n / 5) if mod(n,3)
qui gen y = round((100 - n) / 5) if mod(n,3)
qui gen z = y
qui gen s = string(z)


// test that jumble raises errors when it should
cap jumble a b c d    // these aren't variables
assert _rc == 111

cap jumble n x y z s   // need to use -replace- when no -destinations- given
assert _rc == 110

cap jumble n x y z s , destinations(n2 x2 y2 z2)    // wrong number of destinations
assert _rc == 102

cap jumble n x y z s , destinations(n2 x2 y2 z2 s2 t2)    // wrong number of destinations
assert _rc == 103

cap jumble n x , dest(m x2)    // m already exists, need to use -replace-
assert _rc == 110

cap jumble n x , dest(n2 s) replace    // s is string, can't put numeric in string
assert _rc == 109

cap jumble n s , dest(n2 x) replace    // x is numeric, can't put string in numeric
assert _rc == 109

cap jumble n s , blocks(blockvar) dest(n2 s2)    // no such variable `blockvar`
assert _rc == 111

cap jumble n s , dest(n2 s2)    // no error, setting up for next error
cap jumble n s , dest(n2 s2)    // need to use -replace-
assert _rc == 110
qui drop n2   // clean up

qui gen bfalse = round(_n / 18)
cap jumble n s , blocks(bfalse) dest(n2 s2)    // blocks are not all same size
assert _rc == 459
qui drop bfalse   // clean up


// try an in-place, mixed-type jumble
jumble n x y z s , replace
qui count if n == m
if (r(N) == 100) {    // allow random permutation to same order just once
	jumble n x y z s , replace
}
qui count if n == m
assert r(N) < 100
assert x == round(n / 5) if mod(n,3)
assert y == round((100 - n) / 5) if mod(n,3)
assert z == y
assert s == string(z)

// return data to original
qui drop m
sort n
qui gen m = n


// try a mixed-type jumble putting values in new variables
jumble n x y z s , dest(n2 x2 y2 z2 s2)
qui count if n2 == n
if (r(N) == 100) {    // allow random permutation to same order just once
	jumble n x y z s , dest(n2 x2 y2 z2 s2) replace
}
qui count if n2 == n
assert r(N) < 100
assert x2 == round(n2 / 5) if mod(n2,3)
assert y2 == round((100 - n2) / 5) if mod(n2,3)
assert z2 == y2
assert s2 == string(z2)


// try a mixed-type jumble putting values in new variables, using `in`
jumble n x y z s in 1/50 , dest(n2 x2 y2 z2 s2) replace
qui count if n2 == n in 1/50
if (r(N) == 50) {    // allow random permutation to same order just once
	jumble n x y z s in 1/50 , dest(n2 x2 y2 z2 s2) replace
}
qui count if n2 == n in 1/50
assert r(N) < 50
assert n2 == . in 51/100    // checks that other values are written over when not using -noclear-

assert x2 == round(n2 / 5) if mod(n2,3) in 1/50
assert x2 == . in 51/100

assert y2 == round((100 - n2) / 5) if mod(n2,3) in 1/50
assert y2 == . in 51/100

assert z2 == y2 in 1/50
assert z2 == . in 51/100

assert s2 == string(z2) in 1/50
assert s2 == "" in 51/100


// try a mixed-type jumble putting values in new variables, using `if`
jumble n x y z s if mod(n,3) != 2 , dest(n2 x2 y2 z2 s2) replace
qui count if n2 == n & mod(n,3) != 2
if (r(N) == 67) {    // allow random permutation to same order just once
	jumble n x y z s if mod(n,3) != 2 , dest(n2 x2 y2 z2 s2) replace
}
qui count if n2 == n & mod(n,3) != 2
assert r(N) < 67
assert n2 == . if mod(n,3) == 2

assert x2 == round(n2 / 5) if mod(n2,3) & mod(n,3) != 2
assert x2 == . if mod(n2,3) == 2 | mod(n2,3) == 0

assert y2 == round((100 - n2) / 5) if mod(n2,3) & mod(n,3) != 2
assert y2 == . if mod(n,3) == 2 | mod(n2,3) == 0

assert z2 == y2 if mod(n,3) != 2
assert z2 == . if mod(n,3) == 2 | mod(n2,3) == 0

assert s2 == string(z2) if mod(n,3) != 2
assert s2 == "" if mod(n,3) == 2
assert s2 == "." if mod(n2,3) == 0


// try a mixed-type jumble putting values in new variables, using `if`, without clearing
jumble n x y z s if mod(n,3) == 2 , dest(n2 x2 y2 z2 s2) replace noclear
qui count if n2 == n & mod(n,3) == 2
if (r(N) == 33) {    // allow random permutation to same order just once
	jumble n x y z s if mod(n,3) == 2 , dest(n2 x2 y2 z2 s2) replace noclear
}
qui count if n2 == n & mod(n,3) == 2
assert r(N) < 33
assert n2 != .

assert x2 == round(n2 / 5) if mod(n2,3)
assert x2 != . if mod(n2,3) != 0

assert y2 == round((100 - n2) / 5) if mod(n2,3)
assert y2 != . if mod(n2,3) != 0

assert z2 == y2
assert z2 != . if mod(n2,3) != 0

assert s2 == string(z2)
assert s2 != "." if mod(n2,3) != 0


//------------------------------------------
// Do some of the above again using -blocks-
//------------------------------------------


qui gen b = ceil(_n / 10)

// try an in-place, mixed-type jumble
jumble b n x y z s , blocks(b) replace
qui count if n == m
if (r(N) == 100) {    // allow random permutation to same order just once
	jumble b n x y z s , blocks(b) replace
}
qui count if n == m
assert r(N) < 100
assert mod(r(N), 10) == 0

assert mod(n - m, 10) == 0  // check that obs were not permuted within the 10 blocks

assert x == round(n / 5) if mod(n,3)
assert y == round((100 - n) / 5) if mod(n,3)
assert z == y
assert s == string(z)

// return data to original
qui drop m
sort n
qui gen m = n



// try a mixed-type jumble putting values in new variables
jumble b n x y z s , blocks(b) dest(b2 n2 x2 y2 z2 s2) replace
qui count if n2 == n
if (r(N) == 100) {    // allow random permutation to same order just once
	jumble b n x y z s , blocks(b) dest(b2 n2 x2 y2 z2 s2) replace
}
qui count if n2 == n
assert r(N) < 100
assert mod(r(N), 10) == 0

assert mod(n2 - n, 10) == 0  // check that obs were not permuted within the 10 blocks

assert x2 == round(n2 / 5) if mod(n2,3)
assert y2 == round((100 - n2) / 5) if mod(n2,3)
assert z2 == y2
assert s2 == string(z2)


// try a mixed-type jumble putting values in new variables, using `in`
jumble n x y z s in 1/50 , blocks(b) dest(n2 x2 y2 z2 s2) replace
qui count if n2 == n in 1/50
if (r(N) == 50) {    // allow random permutation to same order just once
	jumble n x y z s in 1/50 , blocks(b) dest(n2 x2 y2 z2 s2) replace
}
qui count if n2 == n in 1/50
assert r(N) < 50
assert mod(r(N), 10) == 0
assert n2 == . in 51/100

assert mod(n2 - n, 10) == 0 in 1/50  // check that obs were not permuted within the 10 blocks

assert x2 == round(n2 / 5) if mod(n2,3) in 1/50
assert x2 == . in 51/100

assert y2 == round((100 - n2) / 5) if mod(n2,3) in 1/50
assert y2 == . in 51/100

assert z2 == y2 in 1/50
assert z2 == . in 51/100

assert s2 == string(z2) in 1/50
assert s2 == "" in 51/100


restore
