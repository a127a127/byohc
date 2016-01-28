define = require('amdefine')(module) if typeof define != 'function'
define(['lodash'], \
       (      _ )->

	ast_to_ir = (ast)->
		new_variable = (name)-> {
			type: 'variable'
			name: name
		}
		ops = {
			lambda: (env)->
				# Lexical scoping
				parameter = new_variable(@arg)
				t = env.symbol[parameter.name]
				env.symbol[parameter.name] = parameter
				expression = trans(@exp, env)
				env.symbol[parameter.name] = t
				return {
					type: 'function'
					parameter
					expression
				}
			application: (env)->
				return {
					type: 'apply'
					function: trans(@function, env)
					arg: trans(@arg, env)
				}
			variable: (env)->
				return env.symbol[@name] ? new_variable("Undefined variable: #{@name}")
		}
		trans = (ast, env)->
			return ops[ast.type].call(ast, env)
		trans(ast, {symbol: {}})

	interpret = (ir)->
		ops = {
			function: (env)->
				return @
			apply: (env)->
				@function = _.cloneDeep(_interpret(@function, env))
				if @function.type == 'function'
					#@arg = _interpret(@arg, env) lazy
					@function.parameter.value = @arg
					return _interpret(@function.expression, env)
				else
					process.exit 1
					return @
			variable: (env)->
				if @value?
					@value = _interpret(@value, env)
					return @value
				else
					return @
		}
		_interpret = (ir, env)->
			return ops[ir.type].call(ir, env)
		return _interpret(ir, {}) # Run with empty environment

	return {
		ast_to_ir: ast_to_ir
		interpret: interpret
	}
)
