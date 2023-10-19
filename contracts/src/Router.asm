codecopy(0, $contract, #contract)
; Return the contract
return(0, #contract)

@contract {
  calldataload(0)  ; [calldata]
  shr(0xe0, $$)    ; [sig]
  pop()
  calldatacopy(0, 0, calldatasize());
  0
  calldatasize()
  0
  0 ; [0, 0, calldatasize, 0]
  ; // TODO get implementation address, for now we leave sig as it
  ; 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0
  pop()
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1
  pop()
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2
  pop()
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3
  delegatecall(gas(), $$,  $$, $$, $$, $$) ; [result]
  returndatacopy(0, 0, returndatasize())
  jumpi($revert, eq(0, $$))
  return(0, returndatasize())
  @revert:
    revert(0, returndatasize())
}
