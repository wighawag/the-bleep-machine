;;; t ∗(0xCA98>>(t>>9&14)&15)| t >>8
;;; t*(0xCA98 >> (t>>9 & 14) & 15)|(t>>8)
;;; (t*((0xCA98>>((t>>9)&14))&15))|(t>>8)
;;; function p(t) { return (t>>8)|(t*((0xCA98>>((t>>9)&14))&15))}

dup1()       ;; [TIME, TIME]
dup1()       ;; [TIME, TIME, TIME]
8            ;; [TIME, TIME, TIME, 08]
shr($$, $$)  ;; [TIME, TIME, t>>8]
swap2()      ;; [t>>8, TIME, TIME]
9            ;; [t>>8, TIME, TIME, 09]
shr($$,$$)   ;; [t>>8, TIME, t>>9]
and(14, $$)  ;; [t>>8, TIME, t>>9&14]
0xCA98       ;; [t>>8, TIME, t>>9&14, 0xCA98]
swap1()      ;; [t>>8, TIME, 0xCA98, t>>9&1]
shr($$, $$)  ;; [t>>8, TIME, (0xCA98>>((t>>9)&14))]
and(15, $$)  ;; [t>>8, TIME, (0xCA98>>((t>>9)&14))&15]
mul($$, $$)  ;; [t>>8, (t*((0xCA98>>((t>>9)&14))&15))]
or($$, $$)

