#!/usr/bin/env coffee
define = require('amdefine')(module) if typeof define != 'function'
define(['readline', './byohc', './byohc_parser'], \
       ( readline ,    byohc ,    byohc_parser )->
	rl = readline.createInterface(
		input: process.stdin,
		output: process.stdout,
		terminal: false
	)

	print_ir = (ir)->
		next_indent = (env)-> {
			indent: env.indent+'  '
		}
		ops = {
			function: (env)->
				process.stdout.write "(lambda (#{@parameter.name})\n"
				process.stdout.write "#{next_indent(env).indent}"
				_print_ir(byohc.interpret(@expression), next_indent(env))
				process.stdout.write ")"
			apply: (env)->
				@arg = byohc.interpret(@arg)
				process.stdout.write "(apply \n"
				process.stdout.write "#{next_indent(env).indent}"
				_print_ir(@function, next_indent(env))
				process.stdout.write "\n"
				process.stdout.write "#{next_indent(env).indent}"
				_print_ir(@arg, next_indent(env))
				process.stdout.write ")"
			variable: (env)->
				if @value?
					return _print_ir(@value, env)
				else
					process.stdout.write "#{@name}"
		}
		_print_ir = (ir, env)->
			return ops[ir.type].call(ir, env)
		_print_ir(ir, {indent: ''})
		process.stdout.write "\n"

	rl.on('line', (line)->
		if line[0] != '#'
			print = yes
			if line[0] == '^'
				print = no
				line = line.substr(1)
			ast = byohc_parser(line)
			ir = byohc.ast_to_ir(ast)
			#console.log JSON.stringify ir, null, 2
			r = byohc.interpret(ir)
			print_ir(r) if print
		else
			console.log line
	)
)
