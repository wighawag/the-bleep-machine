dup1()        ; [TIME, TIME]
shr(10, $$)   ; [TIME, shr(10,t)]
and(42, $$)   ; [TIME, and(shr(10, t), 42)]
mul($$, $$)   ; RESULT = mul(and(shr(10, t), 42), t)
