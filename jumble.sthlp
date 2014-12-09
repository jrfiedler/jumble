{smcl}
{* *! version 1.0.0 5dec2014}{...}

{title:Title}

{phang}
{bf : jumble} {hline 2} permute observations in a subset of variables{p_end}


{title:Syntax}
{p 8 17 2}{cmd:jumble}
{it:varlist}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opth bl:ocks(varlist)}}Jumble blocks of observations. Observations will
	not be permuted within blocks.{p_end}
	
{synopt:{opth dest:inations(varlist)}}Destination for jumbled observations. Without
	specifying, variables will be jumbled in place. If used, the number of 
	specified variables must match the number of jumbled variables. If any of 
	the specified variables already exist, the {opt replace} option is required.{p_end}
	
{synopt:{opt noclear}}Do not clear {opt destinations} variables. When
	{opt destinations} variables already exist and this option is not used, all 
	values will be replaced with missing before jumbled values are inserted.{p_end}
	
{synopt:{opt replace}}Overwrite variables, either when jumbling in place 
	(i.e., without using {opt destinations} option) or when {opt destinations}
	variables already exist.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{phang}
{cmd:jumble} permutes observations or blocks of observations for specified 
	variables. Of course, this is rarely a good idea. Rarely, but not 
	never. Permutation tests, for example, require permuted variables, and sometimes 
	multiple variables need to be permuted. There is a built-in Stata command 
	{cmd:permute} for doing permutation statistics, but {cmd:permute} will only permute
	one variable at a time.

	
{title:Examples}

    {com}. set obs 15
    {txt}obs was 0, now 15
    
    {com}. gen b = ceil(_n / 5)
    
    . gen x = _n if mod(_n,7)
    {txt}(2 missing values generated)
    
    . gen y = 16 - _n if mod(_n,7) != 3
    {txt}(2 missing values generated)
    
    . gen z = substr("abcdefghijklmnopqrstuvwxyz", x, 1)
    {txt}(2 missing values generated)
    
    {com}. list
    {txt}
         {c TLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c TRC}
         {c |} {res}b    x    y   z {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
      1. {c |} {res}1    1   15   a {txt}{c |}
      2. {c |} {res}1    2   14   b {txt}{c |}
      3. {c |} {res}1    3    .   c {txt}{c |}
      4. {c |} {res}1    4   12   d {txt}{c |}
      5. {c |} {res}1    5   11   e {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
      6. {c |} {res}2    6   10   f {txt}{c |}
      7. {c |} {res}2    .    9     {txt}{c |}
      8. {c |} {res}2    8    8   h {txt}{c |}
      9. {c |} {res}2    9    7   i {txt}{c |}
     10. {c |} {res}2   10    .   j {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
     11. {c |} {res}3   11    5   k {txt}{c |}
     12. {c |} {res}3   12    4   l {txt}{c |}
     13. {c |} {res}3   13    3   m {txt}{c |}
     14. {c |} {res}3    .    2     {txt}{c |}
     15. {c |} {res}3   15    1   o {txt}{c |}
         {c BLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c BRC}
    
    {com}. jumble z , replace
    {res}
    {com}. list
    {txt}
         {c TLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c TRC}
         {c |} {res}b    x    y   z {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
      1. {c |} {res}1    1   15   i {txt}{c |}
      2. {c |} {res}1    2   14   h {txt}{c |}
      3. {c |} {res}1    3    .   a {txt}{c |}
      4. {c |} {res}1    4   12     {txt}{c |}
      5. {c |} {res}1    5   11   c {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
      6. {c |} {res}2    6   10   f {txt}{c |}
      7. {c |} {res}2    .    9   o {txt}{c |}
      8. {c |} {res}2    8    8   m {txt}{c |}
      9. {c |} {res}2    9    7   j {txt}{c |}
     10. {c |} {res}2   10    .   l {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c RT}
     11. {c |} {res}3   11    5   d {txt}{c |}
     12. {c |} {res}3   12    4   k {txt}{c |}
     13. {c |} {res}3   13    3   e {txt}{c |}
     14. {c |} {res}3    .    2     {txt}{c |}
     15. {c |} {res}3   15    1   b {txt}{c |}
         {c BLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 3}{c BRC}
    
    {com}. jumble x y z , dest(x2 y2 z2)
    {res}
    {com}. list x2 y2 z2
    {txt}
         {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c TRC}
         {c |} {res}x2   y2   z2 {txt}{c |}
         {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
      1. {c |} {res} .    2      {txt}{c |}
      2. {c |} {res} 3    .    a {txt}{c |}
      3. {c |} {res} 9    7    j {txt}{c |}
      4. {c |} {res} 8    8    m {txt}{c |}
      5. {c |} {res}10    .    l {txt}{c |}
         {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
      6. {c |} {res}15    1    b {txt}{c |}
      7. {c |} {res} .    9    o {txt}{c |}
      8. {c |} {res}11    5    d {txt}{c |}
      9. {c |} {res} 1   15    i {txt}{c |}
     10. {c |} {res} 2   14    h {txt}{c |}
         {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
     11. {c |} {res} 6   10    f {txt}{c |}
     12. {c |} {res}13    3    e {txt}{c |}
     13. {c |} {res} 5   11    c {txt}{c |}
     14. {c |} {res}12    4    k {txt}{c |}
     15. {c |} {res} 4   12      {txt}{c |}
         {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c BRC}
    
    {com}. jumble b x , blocks(b) dest(b2 x2) replace
    {res}
    {com}. list b* x*
    {txt}
         {c TLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c TRC}
         {c |} {res}b   b2    x   x2 {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
      1. {c |} {res}1    1    1    1 {txt}{c |}
      2. {c |} {res}1    1    2    2 {txt}{c |}
      3. {c |} {res}1    1    3    3 {txt}{c |}
      4. {c |} {res}1    1    4    4 {txt}{c |}
      5. {c |} {res}1    1    5    5 {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
      6. {c |} {res}2    3    6   11 {txt}{c |}
      7. {c |} {res}2    3    .   12 {txt}{c |}
      8. {c |} {res}2    3    8   13 {txt}{c |}
      9. {c |} {res}2    3    9    . {txt}{c |}
     10. {c |} {res}2    3   10   15 {txt}{c |}
         {c LT}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c RT}
     11. {c |} {res}3    2   11    6 {txt}{c |}
     12. {c |} {res}3    2   12    . {txt}{c |}
     13. {c |} {res}3    2   13    8 {txt}{c |}
     14. {c |} {res}3    2    .    9 {txt}{c |}
     15. {c |} {res}3    2   15   10 {txt}{c |}
         {c BLC}{hline 3}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c BRC}


{title:Author}

{pstd}
James Fiedler, Universities Space Research Association{break}
Email: {browse "mailto:jrfiedler@gmail.com":jrfiedler@gmail.com}
