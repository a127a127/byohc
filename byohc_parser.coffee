define = require('amdefine')(module) if typeof define != 'function'
define([], \
       ()->
	trans = (input)->
		switch input[0]
			when 'lam'
				return {
					type: 'lambda'
					arg: input[1]
					exp: trans input[2]
				}
			when 'app'
				return {
					type: 'application'
					function: trans input[1]
					arg: trans input[2]
				}
			when 'var'
				return {
					type: 'variable'
					name: input[1]
				}
			else
				console.err "Parse error: unknown type <#{input[0]}>"
				process.exit 1
	return (input_string)->
		input = JSON.parse(input_string)
		return trans(input)
)
