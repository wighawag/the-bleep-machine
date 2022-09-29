codecopy(0, $contract, #contract)
; Return the contract
return(0, #contract)

; // TIME =  calldata last 16 bytes
; // LENGTH =  calldata first 16 bytes
; // OFFSET = in buffer
@contract {
  calldataload(0)  ; [calldata]
  dup1()          ; [calldata, calldata]
  shl(128, $$)  ; [calldata, TIME << 128]
  shr(128, $$)  ; [calldata, TIME]
  dup1()        ; [calldata, TIME, TIME]

  mstore(0, $$) ; [calldata, TIME,]  // TIME stored at 0
  swap1()       ; [TIME, calldata]
  shr(128, $$)  ; [TIME, LENGTH]
  mstore(32, $$) ; [TIME] // LENGTH stored at 32
  mstore(64, 0) ; [TIME] // OFFSET stored at 64

  @loop:
    ; ------------------------------

    ; ------------------------------
    0xff            ; [0x05, 0xff]
    swap1()         ; [0xff, 0x05]
    and($$, $$)     ; [0x05]
    mload(64)       ; [0x05, OFFSET]
    dup1()          ; [0x05, OFFSET, OFFSET]
    add(96, $$)     ; [0x05, OFFSET, BUFFER_INDEX]
    swap1()         ; [0x05, BUFFER_INDEX, OFFSET]
    swap2()         ; [OFFSET, BUFFER_INDEX, 0x05]
    swap1()         ; [OFFSET, 0x05, BUFFER_INDEX]
    mstore8($$, $$)  ; [OFFSET]
    add(1, $$)      ; [OFFSET] // + 1
    dup1()          ; [OFFSET, OFFSET]
    mstore(64, $$)  ; [OFFSET]
    mload(32)       ; [OFFSET, LENGTH]
    mload(0)        ; [OFFSET, LENGTH, TIME]
    add(1, $$)      ; [OFFSET, LENGTH, TIME] + 1
    dup1()          ; [OFFSET, LENGTH, TIME, TIME]
    mstore(0, $$)   ; [OFFSET, LENGTH, TIME]
    swap2()         ; [TIME, OFFSET, LENGTH]
  jumpi($loop, lt($$, $$)) ; [TIME]

  mload(32)         ; [TIME, LENGTH]  (get the length from memory)
  return (96, $$)  ;
}
