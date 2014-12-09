program jumble , sortpreserve

syntax varlist [in] [if] [ ,                                 ///
	BLocks(varlist) DESTinations(namelist) replace noclear   ///
]

marksample touse , novarlist strok

qui count if `touse'
local nobs = r(N)

if (`nobs' == 0) {
	exit
}

unab inputs : `varlist'
local ninputs = wordcount("`inputs'")

if ("`blocks'" != "") {
	tempvar blockid
	qui egen `blockid' = group(`blocks') if `touse', missing
	qui summ `blockid'
	local nblocks = r(max)
	
	qui sort `blockid'
	
	qui count if `blockid' == 1
	local nper = r(N)
	forv i=2(1)`nblocks' {
		qui count if `blockid' == `i'
		if (r(N) != `nper') {
			noi di as error "blocks defined by -blocks- option do not have same size"
			exit 459
		}
	}
}

if ("`destinations'" == "") {
	if ("`replace'" == "") {
		noi di as error "-destinations- not specified"
		noi di as error "use -replace- if intending to replace input variables"
		exit 110
	}
	if ("`blocks'" == "") {
		mata: jumble_vars_inplace("`inputs'", "`touse'", `nobs')
	}
	else {
		mata: jumble_vars_inplace("`inputs'", "`touse'", `nobs', "`blockid'", `nblocks')
	}
}
else {
	local noutputs = wordcount("`destinations'")
	if (`noutputs' != `ninputs') {
		local errnum = cond(`noutputs' < `ninputs', 102, 103)
		noi di as error "there are `ninputs' input variables and `noutputs' destinations"
		exit `errnum'
	}
	
	forv i=1(1)`ninputs' {
		local input = word("`inputs'", `i')
		local output = word("`destinations'", `i')
	
		local inputtype : type `input'
		local inputclass = cond(substr("`inputtype'", 1, 3) == "str", "string", "numeric")
		local missval = cond("`inputclass'" == "string", `""""', ".")
		
		cap confirm variable `output'
		if (!_rc) {
			if ("`replace'" == "") {
				noi di as error "`output' exists; use the -replace- option to replace"
				exit 110
			}
			cap confirm `inputclass' variable `output'
			if (_rc) {
				noi di as error "`output' data type is not compatible with `input' type"
				exit 109
			}
			if ("`clear'" != "noclear") {
				qui replace `output' = `missval'
			}
			
			cap confirm `inputtype' variable `output'
			if (_rc) {
				noi di as error "`output' will be recast to same type as `input'"
				qui recast `inputtype' `output'
			}
		}
		else {
			qui gen `inputtype' `output' = `missval'
		}
	}
	
	if ("`blocks'" == "") {
		mata: jumble_vars("`inputs'", "`destinations'", "`touse'", `nobs')
	}
	else {
		mata: jumble_vars("`inputs'", "`destinations'", "`touse'", `nobs', "`blockid'", `nblocks')
	}
}

end


mata
real vector make_sortord(real scalar nobs)
{
	real vector r, sortord

	r = runiform(nobs, 1)
	sortord = order(r, 1)
	
	return(sortord)
}


real vector make_block_sortord(
	string scalar blockid, real scalar nblocks,
	string scalar touse, real scalar nobs
)
{
	real vector sortord, bsortord, B
	real scalar i, b, t
	pointer vector indices
	
	st_view(B, ., blockid, touse)
	
	// establish sort order of blocks
	bsortord = make_sortord(nblocks)
	
	// establish sort order of observations
	indices = J(nblocks, 1, NULL)
	sortord = J(nobs, 1, .)
	
	i = 1
	while (i <= nobs) {
		b = B[i]
		while (B[i] == b) {
			if (indices[b] == NULL) {
				indices[b] = &J(1,1,i)
			}
			else {
				indices[b] = &(*(indices[b]) \ i)
			}
			i++
			if (i > nobs) {
				break
			}
		}
	}
	
	indices[.,.] = indices[bsortord,.]
	
	t = 1
	for (b = 1; b <= nblocks; b++) {
		for (i = 1; i <= rows(*(indices[b])); i++) {
			sortord[t] = (*(indices[b]))[i]
			t++
		}
	}
	
	return(sortord)
}

void jumble_vars(
	string scalar inputs, string scalar outputs,
	string scalar touse, real scalar nobs,
	| string scalar blockid, real scalar nblocks
)
{
	transmorphic vector X, Y
	real vector r, sortord
	real scalar in_beg, in_end, out_beg, out_end, inputs_len, outputs_len
	string scalar input, output
	
	inputs_len = strlen(inputs)
	outputs_len = strlen(outputs)
	
	// get random sort order of observations
	if (args() == 4) {
		sortord = make_sortord(nobs)
	}
	else {
		sortord = make_block_sortord(blockid, nblocks, touse, nobs)
	}
	
	in_beg = 1
	out_beg = 1
	while (in_beg <= inputs_len) {
		// move `in_beg` and `out_beg` beyond any initial spaces
		while (substr(inputs, in_beg, 1) == " ") {
			in_beg++
		}
		while (substr(outputs, out_beg, 1) == " ") {
			out_beg++
		}
		
		in_end = in_beg + 1
		while (in_end <= inputs_len && substr(inputs, in_end, 1) != " ") {
			in_end++
		}
		
		out_end = out_beg + 1
		while (out_end <= outputs_len && substr(outputs, out_end, 1) != " ") {
			out_end++
		}
		
		input = substr(inputs, in_beg, in_end - in_beg)
		output = substr(outputs, out_beg, out_end - out_beg)
		
		st_sview(X, ., input, touse)
		
		if (st_isstrvar(input)) {
			st_sview(X, ., input, touse)
			st_sview(Y, ., output, touse)
		}
		else {
			st_view(X, ., input, touse)
			st_view(Y, ., output, touse)
		}
		
		Y[.,.] = X[sortord, .]
		
		in_beg = in_end
		out_beg = out_end
	}
}

void jumble_vars_inplace(
	string scalar inputs,
	string scalar touse, real scalar nobs,
	| string scalar blockid, real scalar nblocks
)
{
	transmorphic vector X
	real vector r, sortord
	real scalar in_beg, in_end, inputs_len
	string scalar input
	
	inputs_len = strlen(inputs)
	
	// get random sort order of observations
	if (args() == 3) {
		sortord = make_sortord(nobs)
	}
	else {
		sortord = make_block_sortord(blockid, nblocks, touse, nobs)
	}
	
	in_beg = 1
	while (in_beg <= inputs_len) {
		// move `in_beg` beyond any initial spaces
		while (substr(inputs, in_beg, 1) == " ") {
			in_beg++
		}
		
		in_end = in_beg + 1
		while (in_end <= inputs_len && substr(inputs, in_end, 1) != " ") {
			in_end++
		}
		
		input = substr(inputs, in_beg, in_end - in_beg)
		
		if (st_isstrvar(input)) {
			st_sview(X, ., input, touse)
		}
		else {
			st_view(X, ., input, touse)
		}
		
		X[.,.] = X[sortord, .]
		
		in_beg = in_end
	}
}
end
