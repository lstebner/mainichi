NodeArgs = require("./nodeargs")
fs = require("fs")
colors = require("colors")

process_args = new NodeArgs()

DEBUG_MODE = process_args.has_flag("--debug")

_debug = (msg) ->
  return unless DEBUG_MODE
  console.log colors.yellow msg

class Generator
  constructor: ->
    @data = []
    @generate()

  generate: ->
    console.log "generator generate not yet implemented"

  write_file: (filename) ->
    fs.writeFile "#{__dirname}/dictionaries/#{filename}.csv", @data.join("\n")


class BasicMathGenerator extends Generator
  generate: ->
    _debug "generating..."
    how_many = 100
    operators = ["+", "-"]
    max_num = 99

    dictionary_data = for i in [0..how_many]
      operator = operators[Math.floor Math.random() * operators.length]
      num1 = Math.ceil Math.random() * max_num
      num2 = Math.ceil Math.random() * max_num
      problem = "#{num1} #{operator} #{num2}"
      answer = eval(problem)
      [problem, answer]

    _debug "generated #{how_many} basic math problems"

    @data = dictionary_data
    @write_file "basic_math_#{(new Date).getTime()}"


generator = null

_debug "generator starting for #{process_args.val('--dictionary')}"

switch process_args.val "--dictionary"
  when "basic_math" then generator = new BasicMathGenerator()
