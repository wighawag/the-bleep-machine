import 'dotenv/config';
import fs from 'fs-extra';
import path from 'path';
import {assemble, parse} from '@ethersproject/asm';

import {parseBytecode, generateBytecode} from './evm-parser';

async function getBytecode(filename: string, target?: string): Promise<string> {
	const source = fs.readFileSync(filename).toString();
	try {
		const ast = parse(source);
		const bytecode = await assemble(ast, {target: target});
		//console.log(`Bytecode (${ filename }): ${ bytecode }`);
		return bytecode;
	} catch (err) {
		if (Array.isArray(err)) {
			err.forEach((error) => console.error(error));
		} else {
			console.log(err);
		}
		throw err;
	}
}

async function compile(filename: string) {
	const bytecode = await getBytecode(filename);
	if (!bytecode) {
		throw new Error(`no bytecode`);
	}
	const name = getFilenameWithoutExtesnsion(filename);
	fs.ensureDirSync(`artifacts/bytecodes`);

	fs.writeFileSync(`artifacts/bytecodes/${name}.bytecode`, bytecode);
	const matches = bytecode.match(/(.{1,2})/g);
	if (!matches) {
		throw new Error(`no matches for splitting`);
	}
	fs.writeFileSync(`artifacts/bytecodes/${name}.bytecode.splitted`, matches.join('\n'));
	const operations = parseBytecode(bytecode);
	fs.writeFileSync(`artifacts/bytecodes/${name}.operations`, operations);
	const bytecodeGeneratedAGain = generateBytecode(operations);
	fs.writeFileSync(`artifacts/bytecodes/${name}.operations.bytecode`, bytecodeGeneratedAGain);
	return bytecode;
}

function getFilenameWithoutExtesnsion(filepath: string): string {
	const basename = path.basename(filepath);
	return basename.slice(0, basename.length - path.extname(basename).length);
}

async function main() {
	const args = process.argv.slice(2);
	const filename = args[0];
	const bytecode = await compile(filename);
	const matches = bytecode.match(/(.{1,2})/g);
	if (!matches) {
		throw new Error(`no matches for splitting`);
	}
	const name = getFilenameWithoutExtesnsion(filename);
	fs.ensureDirSync(`artifacts/bytecodes`);
	fs.writeFileSync(`artifacts/bytecodes/${name}.bytecode`, bytecode);
	fs.writeFileSync(`artifacts/bytecodes/${name}.bytecode.splitted`, matches.join('\n'));
	const operations = parseBytecode(bytecode);
	fs.writeFileSync(`artifacts/bytecodes/${name}.operations`, operations);
}
main();
