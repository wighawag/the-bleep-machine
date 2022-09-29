codecopy(0, $contract, #contract)
; Return the contract
return(0, #contract)

; // START =  calldata last 16 bytes
; // LENGTH =  calldata first 16 bytes
; // OFFSET = in buffer
@contract {
  calldataload(0)   ; [calldata]
  dup1()            ; [calldata, calldata]
  shl(128, $$)      ; [calldata, START << 128]
  shr(128, $$)      ; [calldata, START]
  dup1()            ; [calldata, START, START]

  mstore(0, $$)     ; [calldata, START]  // START stored at 0
  swap1()           ; [START, calldata]
  shr(128, $$)      ; [START, LENGTH]
  mstore(32, $$)    ; [START] // LENGTH stored at 32

  @loop:
    ; ------------------------------

    ; ------------------------------
		mload(64)       ; [0x05, OFFSET]
		swap1()         ; [OFFSET, 0x05]
    0xff            ; [OFFSET, 0x05, 0xff]
    and($$, $$)     ; [OFFSET, 0x05]
    dup2()          ; [OFFSET, 0x05, OFFSET]
    add(96, $$)     ; [OFFSET, 0x05, BUFFER_INDEX]
		mstore8($$, $$) ; [OFFSET]
    add(1, $$)      ; [OFFSET+1]
    dup1()          ; [OFFSET+1, OFFSET+1]
    mstore(64, $$)  ; [OFFSET+1]
    mload(0)        ; [OFFSET+1, START]
		dup2()          ; [OFFSET+1, START, OFFSET+1]
		add($$,$$)      ; [OFFSET+1, TIME]
		swap1()         ; [TIME, OFFSET+1]
		mload(32)				; [TIME, OFFSET+1, LENGTH]
		gt($$, $$)      ; [TIME, LENGTH > OFFSET+1]
  jumpi($loop, $$)  ; [TIME]

  mload(32)         ; [TIME, LENGTH]  (get the length from memory)
  return (96, $$)   ;
}
