NodeArgs = require("./nodeargs")
fs = require("fs")
colors = require("colors")
_ = require("underscore")

process_args = new NodeArgs()

DEBUG_MODE = process_args.has_flag("--debug")

no_safety = process_args.has_flag(["--no-safety", "--unsafe"])
if no_safety
  console.log colors.yellow "no_safety mode"

_debug = (msg) ->
  return unless DEBUG_MODE
  console.log colors.yellow msg

class Generator
  constructor: ->
    @data = []
    @generate()

  generate: ->
    console.log "generator generate not yet implemented"

  write_file: ->
    filename = @filename_prefix
    unless no_safety
      filename += "_#{(new Date).getTime()}"

    fs.writeFile "#{__dirname}/dictionaries/#{filename}.csv", @data.join("\n")
    _debug "wrote file #{filename}"


class BasicMathGenerator extends Generator
  generate: ->
    level = if process_args.has_flag("--level")
      process_args.val("--level")
    else
      "easy"
    _debug "generating..."
    how_many = 999
    operators = ["+", "-"]
    levels = ["easy", "medium", "hard", "expert"] 
    if _.indexOf(levels, level) < 0
      console.log colors.red "level '#{level}' isn't one of #{levels.join(', ')}"
      level = 0

    max_num = switch level
      when "easy" || 0 then 20
      when "medium" || 1 then 50
      when "hard" || 2 then 99
      when "expert" || 3 then 999

    level_nice = if typeof level == "number"
      levels[level]
    else
      level

    _debug "selected level: #{level}"

    @data = for i in [0..how_many]
      operator = operators[Math.floor Math.random() * operators.length]
      num1 = Math.ceil Math.random() * max_num
      num2 = Math.ceil Math.random() * max_num
      problem = "#{num1} #{operator} #{num2}"
      answer = eval(problem)
      [problem, answer]

    _debug "generated #{how_many} '#{level_nice}' basic math problems"

    @filename_prefix = "basic_math_#{level_nice}"
    @write_file()


class TimesTableGenerator extends Generator
  generate: ->
    _debug "generating..."

    @data = []

    for num1 in [1..12]
      for num2 in [1..12]
        problem = "#{num1} * #{num2}"
        answer = eval problem
        @data.push [problem, answer] 

    @filename_prefix = "times_tables"
    @write_file()



generator = null

_debug "generator starting for #{process_args.val('--dictionary')}"

switch process_args.val "--dictionary"
  when "basic_math" then generator = new BasicMathGenerator()
  when "times_tables" then generator = new TimesTableGenerator()
