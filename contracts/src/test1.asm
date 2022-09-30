; t & (t >> 8)
              ; [TIME]
dup1()        ; [TIME, TIME]
shr(8, $$)    ; [TIME, TMP]
swap1()       ; [TMP, TIME]
and($$, $$)   ; [RESULT]
