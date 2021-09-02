mkdir -p data
cd data

function get() { wget --content-disposition $1/download }

get https://vault.cs.uwaterloo.ca/s/FBxsZSLMCeLZDMk
get https://vault.cs.uwaterloo.ca/s/ALw3SwqjFCADz2c
get https://vault.cs.uwaterloo.ca/s/w2SBQmAbowi3x3s
get https://vault.cs.uwaterloo.ca/s/3feSbYa36Hw7Fo7
get https://vault.cs.uwaterloo.ca/s/JrFc9XKmx5HWxHQ
get https://vault.cs.uwaterloo.ca/s/kCnwdZ3G9HTJerk
ls *.pairs.* > shards-for-pairs.txt

get https://vault.cs.uwaterloo.ca/s/MEybM72mgtDXMDp
get https://vault.cs.uwaterloo.ca/s/CiSsWLPoJ7j6TKn
get https://vault.cs.uwaterloo.ca/s/68Jo7XwTMbLrZP7
get https://vault.cs.uwaterloo.ca/s/KWQoXNHcEzDDxJn
get https://vault.cs.uwaterloo.ca/s/M5Snx4TLyLrcPia
get https://vault.cs.uwaterloo.ca/s/HCCereecb2DR8Po
get https://vault.cs.uwaterloo.ca/s/GLHBJd6L5a99cqt
ls *.tags.* > shards-for-tags.txt
