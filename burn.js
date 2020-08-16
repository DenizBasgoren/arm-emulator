/*

How to use:
let dir = 'path/to/src/'
let arr = `
	some.s another.s		<- These will be passed to arm-none-eabi-as
	main.c apple.c			<- These will be passed to arm-none-eabi-gcc
	system.puh orange.puh	<- These will be passed to puhuc
	one.c					<- Then this will be passed to arm-none-eabi-gcc
`
*/

// EDIT HERE
let dir = 'samples'
let arr = `

gpuflag.s

`
// EDIT END


let { execSync } = require('child_process')
let { exit } = require('process')

let rels = []
let junks = []
function newFileName(isRel) {
	let j = `${junks.length}`
	junks.push(j)
	if (isRel) rels.push(j)
	return j
}
function cleanJunksAndExit() {
	execSync(`rm -f ${junks.join(' ')}`)
	exit(0)
}
function prependDir(entry) {
	return entry.split(/\s+/).filter(a => a).map(e => {
		if (e[0] == '-') return `${e}` // dont prepend dir to params
		else return `${dir}${e}`
	}).join(' ')
}

if (dir[dir.length-1] != '/') dir = dir.trim() + '/'

let cmds = []
arr.split('\n').filter(line => !/$\s*^/.test(line) ).forEach(entry => {

	let firstElem =  entry.split(/\s+/)[0]
	let partsOfFirstElem = firstElem.split('.')
	let extension = partsOfFirstElem[ partsOfFirstElem.length - 1 ].toLowerCase()

	if (extension == 'c') {
		let n = newFileName(true)
		cmds.push(`arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb -c ${prependDir(entry)} -o ${n}`)
	}
	else if (extension == 's') {
		let n = newFileName(true)
		cmds.push(`arm-none-eabi-as -mcpu=cortex-m0 -mthumb ${prependDir(entry)} -o ${n}`)
	}
	else if (extension == 'puh') {
		let n = newFileName(false)
		cmds.push(`puhuc ${prependDir(entry)} -o ${n}`)
		let n2 = newFileName(true)
		cmds.push(`arm-none-eabi-as -mcpu=cortex-m0 -mthumb ${n} -o ${n2}`)
	}
	else {
		console.log(`Error: ${prependDir(entry)} is not source file`)
		cleanJunksAndExit()
	}
})


let n = 'dist-linux/armapp.elf'
cmds.push(`arm-none-eabi-ld ${rels.join(' ')} -T linker.ld -L /usr/lib/gcc/arm-none-eabi/10.1.0/thumb/v6-m/nofp/ -lgcc -o ${n}`)
cmds.push(`arm-none-eabi-objcopy -O binary -j .text ${n} dist-linux/rom`)
cmds.push(`arm-none-eabi-objcopy -O binary -j .data ${n} dist-linux/ram`)

cmds.forEach(cmd => {

	try {
		execSync(cmd).toString('utf8')
	} catch(er) {
		cleanJunksAndExit()
	}
})

console.log('Images are ready at dist-linux/rom and dist-linux/ram')
cleanJunksAndExit()

