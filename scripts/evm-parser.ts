export type Operator = {
	mnemonic: string;
	stackInput: string[];
	stackOutput: string[];
	bytesInput?: number;
};

type Operators = {[hex: string]: Operator};

const operators: Operators = {
	'00': {
		mnemonic: 'STOP',
		stackInput: [],
		stackOutput: []
	},
	'01': {
		mnemonic: 'ADD',
		stackInput: ['a', 'b'],
		stackOutput: ['a + b']
	},
	'02': {
		mnemonic: 'MUL',
		stackInput: ['a', 'b'],
		stackOutput: ['a * b']
	},
	'03': {
		mnemonic: 'SUB',
		stackInput: ['a', 'b'],
		stackOutput: ['a - b']
	},
	'04': {
		mnemonic: 'DIV',
		stackInput: ['a', 'b'],
		stackOutput: ['a // b']
	},
	'05': {
		mnemonic: 'SDIV',
		stackInput: ['a', 'b'],
		stackOutput: ['a // b']
	},
	'06': {
		mnemonic: 'MOD',
		stackInput: ['a', 'b'],
		stackOutput: ['a % b']
	},
	'07': {
		mnemonic: 'SMOD',
		stackInput: ['a', 'b'],
		stackOutput: ['a % b']
	},
	'08': {
		mnemonic: 'ADDMOD',
		stackInput: ['a', 'b', 'N'],
		stackOutput: ['(a + b) % N']
	},
	'09': {
		mnemonic: 'MULMOD',
		stackInput: ['a', 'b', 'N'],
		stackOutput: ['(a * b) % N']
	},
	'0A': {
		mnemonic: 'EXP',
		stackInput: ['a', 'exponent'],
		stackOutput: ['a ** exponent']
	},
	'0B': {
		mnemonic: 'SIGNEXTEND',
		stackInput: ['b', 'x'],
		stackOutput: ['y']
	},
	10: {
		mnemonic: 'LT',
		stackInput: ['a', 'b'],
		stackOutput: ['a < b']
	},
	11: {
		mnemonic: 'GT',
		stackInput: ['a', 'b'],
		stackOutput: ['a > b']
	},
	12: {
		mnemonic: 'SLT',
		stackInput: ['a', 'b'],
		stackOutput: ['a < b']
	},
	13: {
		mnemonic: 'SGT',
		stackInput: ['a', 'b'],
		stackOutput: ['a > b']
	},
	14: {
		mnemonic: 'EQ',
		stackInput: ['a', 'b'],
		stackOutput: ['a == b']
	},
	15: {
		mnemonic: 'ISZERO',
		stackInput: ['a'],
		stackOutput: ['a == 0']
	},
	16: {
		mnemonic: 'AND',
		stackInput: ['a', 'b'],
		stackOutput: ['a & b']
	},
	17: {
		mnemonic: 'OR',
		stackInput: ['a', 'b'],
		stackOutput: ['a | b']
	},
	18: {
		mnemonic: 'XOR',
		stackInput: ['a', 'b'],
		stackOutput: ['a ^ b']
	},
	19: {
		mnemonic: 'NOT',
		stackInput: ['a'],
		stackOutput: ['~a']
	},
	'1A': {
		mnemonic: 'BYTE',
		stackInput: ['i', 'x'],
		stackOutput: ['x[i]']
	},
	'1B': {
		mnemonic: 'SHL',
		stackInput: ['shift', 'value'],
		stackOutput: ['value << shift']
	},
	'1C': {
		mnemonic: 'SHR',
		stackInput: ['shift', 'value'],
		stackOutput: ['value >> shift']
	},
	'1D': {
		mnemonic: 'SAR',
		stackInput: ['shift', 'value'],
		stackOutput: ['value >> shift']
	},
	20: {
		mnemonic: 'SHA3',
		stackInput: ['offset', 'size'],
		stackOutput: ['hash']
	},
	30: {
		mnemonic: 'ADDRESS',
		stackInput: [],
		stackOutput: ['address']
	},
	31: {
		mnemonic: 'BALANCE',
		stackInput: ['address'],
		stackOutput: ['balance']
	},
	32: {
		mnemonic: 'ORIGIN',
		stackInput: [],
		stackOutput: ['address']
	},
	33: {
		mnemonic: 'CALLER',
		stackInput: [],
		stackOutput: ['address']
	},
	34: {
		mnemonic: 'CALLVALUE',
		stackInput: [],
		stackOutput: ['value']
	},
	35: {
		mnemonic: 'CALLDATALOAD',
		stackInput: ['i'],
		stackOutput: ['data[i]']
	},
	36: {
		mnemonic: 'CALLDATASIZE',
		stackInput: [],
		stackOutput: ['size']
	},
	37: {
		mnemonic: 'CALLDATACOPY',
		stackInput: ['destOffset', 'offset', 'size'],
		stackOutput: []
	},
	38: {
		mnemonic: 'CODESIZE',
		stackInput: [],
		stackOutput: ['size']
	},
	39: {
		mnemonic: 'CODECOPY',
		stackInput: ['destOffset', 'offset', 'size'],
		stackOutput: []
	},
	'3A': {
		mnemonic: 'GASPRICE',
		stackInput: [],
		stackOutput: ['price']
	},
	'3B': {
		mnemonic: 'EXTCODESIZE',
		stackInput: ['address'],
		stackOutput: ['size']
	},
	'3C': {
		mnemonic: 'EXTCODECOPY',
		stackInput: ['address', 'destOffset', 'offset', 'size'],
		stackOutput: []
	},
	'3D': {
		mnemonic: 'RETURNDATASIZE',
		stackInput: [],
		stackOutput: ['size']
	},
	'3E': {
		mnemonic: 'RETURNDATACOPY',
		stackInput: ['destOffset', 'offset', 'size'],
		stackOutput: []
	},
	'3F': {
		mnemonic: 'EXTCODEHASH',
		stackInput: ['address'],
		stackOutput: ['hash']
	},
	40: {
		mnemonic: 'BLOCKHASH',
		stackInput: ['blockNumber'],
		stackOutput: ['hash']
	},
	41: {
		mnemonic: 'COINBASE',
		stackInput: [],
		stackOutput: ['address']
	},
	42: {
		mnemonic: 'TIMESTAMP',
		stackInput: [],
		stackOutput: ['timestamp']
	},
	43: {
		mnemonic: 'NUMBER',
		stackInput: [],
		stackOutput: ['blockNUmber']
	},
	44: {
		mnemonic: 'DIFFICULTY',
		stackInput: [],
		stackOutput: ['difficulty']
	},
	45: {
		mnemonic: 'GASLIMIT',
		stackInput: [],
		stackOutput: ['gasLimit']
	},
	46: {
		mnemonic: 'CHAINID',
		stackInput: [],
		stackOutput: ['chainId']
	},
	47: {
		mnemonic: 'SELFBALANCE',
		stackInput: [],
		stackOutput: ['balance']
	},
	48: {
		mnemonic: 'BASEFEE',
		stackInput: [],
		stackOutput: ['baseFee']
	},
	50: {
		mnemonic: 'POP',
		stackInput: ['y'],
		stackOutput: []
	},
	51: {
		mnemonic: 'MLOAD',
		stackInput: ['offset'],
		stackOutput: ['value']
	},
	52: {
		mnemonic: 'MSTORE',
		stackInput: ['offset', 'value'],
		stackOutput: []
	},
	53: {
		mnemonic: 'MSTORE8',
		stackInput: ['offset', 'value'],
		stackOutput: []
	},
	54: {
		mnemonic: 'SLOAD',
		stackInput: ['key'],
		stackOutput: ['value']
	},
	55: {
		mnemonic: 'SSTORE',
		stackInput: ['key', 'value'],
		stackOutput: []
	},
	56: {
		mnemonic: 'JUMP',
		stackInput: ['counter'],
		stackOutput: []
	},
	57: {
		mnemonic: 'JUMPI',
		stackInput: ['counter', 'b'],
		stackOutput: []
	},
	58: {
		mnemonic: 'PC',
		stackInput: [],
		stackOutput: ['counter']
	},
	59: {
		mnemonic: 'MSIZE',
		stackInput: [],
		stackOutput: ['size']
	},
	'5A': {
		mnemonic: 'GAS',
		stackInput: [],
		stackOutput: ['gas']
	},
	'5B': {
		mnemonic: 'JUMPDEST',
		stackInput: [],
		stackOutput: []
	},
	80: {
		mnemonic: 'DUP1',
		stackInput: ['value'],
		stackOutput: ['value', 'value']
	},
	81: {
		mnemonic: 'DUP2',
		stackInput: ['a', 'b'],
		stackOutput: ['b', 'a', 'b']
	},
	82: {
		mnemonic: 'DUP3',
		stackInput: ['a', 'b', 'c'],
		stackOutput: ['c', 'a', 'b', 'c']
	},
	83: {
		mnemonic: 'DUP4',
		stackInput: ['a', 'b', 'c', 'd'],
		stackOutput: ['d', 'a', 'b', 'c', 'd']
	},
	84: {
		mnemonic: 'DUP5',
		stackInput: ['a', 'b', 'c', 'd', 'e'],
		stackOutput: ['e', 'a', 'b', 'c', 'd', 'e']
	},
	85: {
		mnemonic: 'DUP5',
		stackInput: ['a', 'b', 'c', 'd', 'e', 'f'],
		stackOutput: ['f', 'a', 'b', 'c', 'd', 'e', 'f']
	},
	86: {
		mnemonic: 'DUP6',
		stackInput: ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
		stackOutput: ['g', 'a', 'b', 'c', 'd', 'e', 'f', 'g']
	},
	// TODO ...DUP16
	90: {
		mnemonic: 'SWAP1',
		stackInput: ['a', 'b'],
		stackOutput: ['b', 'a']
	},
	91: {
		mnemonic: 'SWAP2',
		stackInput: ['a', 'b', 'c'],
		stackOutput: ['c', 'b', 'a']
	},
	92: {
		mnemonic: 'SWAP3',
		stackInput: ['a', 'b', 'c', 'd'],
		stackOutput: ['d', 'b', 'c', 'a']
	},
	// TODO ...SWAP16
	A0: {
		mnemonic: 'LOG0',
		stackInput: ['offset', 'size'],
		stackOutput: []
	},
	A1: {
		mnemonic: 'LOG1',
		stackInput: ['offset', 'size', 'topic'],
		stackOutput: []
	},
	A2: {
		mnemonic: 'LOG2',
		stackInput: ['offset', 'size', 'topic1', 'topic2'],
		stackOutput: []
	},
	A3: {
		mnemonic: 'LOG3',
		stackInput: ['offset', 'size', 'topic1', 'topic2', 'topic3'],
		stackOutput: []
	},
	A4: {
		mnemonic: 'LOG4',
		stackInput: ['offset', 'size', 'topic1', 'topic2', 'topic3', 'topic4'],
		stackOutput: []
	},
	F0: {
		mnemonic: 'CREATE',
		stackInput: ['value', 'offset', 'size'],
		stackOutput: ['address']
	},
	F1: {
		mnemonic: 'CALL',
		stackInput: ['gas', 'address', 'value', 'argsOffset', 'argsSize', 'retOffset', 'retSize'],
		stackOutput: ['success']
	},
	F2: {
		mnemonic: 'CALLCODE',
		stackInput: ['gas', 'address', 'value', 'argsOffset', 'argsSize', 'retOffset', 'retSize'],
		stackOutput: ['success']
	},
	F3: {
		mnemonic: 'RETURN',
		stackInput: ['offset', 'size'],
		stackOutput: []
	},
	F4: {
		mnemonic: 'DELEGATECALL',
		stackInput: ['gas', 'address', 'argsOffset', 'argsSize', 'retOffset', 'retSize'],
		stackOutput: ['success']
	},
	F5: {
		mnemonic: 'CREATE2',
		stackInput: ['value', 'offset', 'size', 'salt'],
		stackOutput: ['address']
	},
	FA: {
		mnemonic: 'STATICCALL',
		stackInput: ['gas', 'address', 'argsOffset', 'argsSize', 'retOffset', 'retSize'],
		stackOutput: ['success']
	},
	FD: {
		mnemonic: 'REVERT',
		stackInput: ['offset', 'size'],
		stackOutput: []
	},
	FE: {
		mnemonic: 'INVALID',
		stackInput: [],
		stackOutput: []
	},
	FF: {
		mnemonic: 'SELFDESTRUCT',
		stackInput: ['address'],
		stackOutput: []
	}
};

function generatePushOpcodes(operators: Operators, start: string, num: number) {
	let index = parseInt(start, 16);
	let numInputs = 1;
	for (let i = index; i < index + num; i++) {
		operators[i.toString(16)] = {
			mnemonic: 'PUSH' + numInputs,
			bytesInput: numInputs,
			stackInput: [],
			stackOutput: []
		};
		numInputs++;
	}
}

generatePushOpcodes(operators, '60', 32);
// TODO for DUP and SWAP

function findOperator(mnemonic: string) {
	const keys = Object.keys(operators);
	for (const key of keys) {
		const operator = operators[key];
		if (mnemonic == operator.mnemonic) {
			return {byte: key, operator};
		}
	}
	return undefined;
}

const unknownOperator = {
	mnemonic: 'UNKNOWN',
	stackInput: [],
	stackOutput: []
};
function operationFromOperator(operator: Operator, bytes: string[]) {
	const numInputs = operator.bytesInput || 0;
	let inputStr = '';
	for (let i = 0; i < numInputs; i++) {
		inputStr += ' ' + bytes.shift();
	}
	return {
		str: `${operator.mnemonic}${inputStr}`
	};
}

export function parseBytecode(bytecode: string) {
	const operations = [];
	const bytes = (bytecode.startsWith('0x') ? bytecode.slice(2) : bytecode).match(/(.{1,2})/g);
	if (!bytes) {
		throw new Error(`parsing error`);
	}
	while (bytes.length > 0) {
		const byte = bytes.shift();
		if (!byte) {
			throw new Error(`no more bytes`);
		}
		try {
			let operator = operators[byte.toUpperCase()];
			if (!operator) {
				operator = unknownOperator;
			}
			const operation = operationFromOperator(operator, bytes);
			operations.push(operation);
		} catch (e) {
			console.error({byte, bytes, operations});

			throw e;
		}
	}

	let str = '';
	for (const operation of operations) {
		str += operation.str + '\n';
	}
	return str;
}

export function generateBytecode(operationsStr: string) {
	const lines = operationsStr.split('\n');
	let bytecode = '0x';
	for (const line of lines) {
		if (!line.trim()) {
			continue;
		}
		const split = line.split(' ');
		const mnemonic = split.shift();
		if (!mnemonic) {
			throw new Error(`no more mnemonic`);
		}
		const operatorFound = findOperator(mnemonic);
		if (!operatorFound) {
			throw new Error(`operator not found : ${mnemonic}`);
		} else {
			bytecode += operatorFound.byte + split.join('');
		}
	}

	return bytecode.toLowerCase();
}
