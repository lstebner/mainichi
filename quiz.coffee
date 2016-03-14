prompt = require("prompt")
colors = require("colors")
_ = require("underscore")
_str = require("underscore.string")
fs = require("fs")

class NodeArgs
  constructor: ->
    @args = {}
    @flags = []
    @keys = []

    for arg in process.argv
      if arg.indexOf("=") > -1
        sp = arg.split("=")
        @args[sp[0]] = sp[1]
        @keys.push sp[0]
      else
        @args[arg] = 1
        @flags.push arg

  on: (flag_or_key, fn=null) ->
    found_flag = @flags.indexOf(flag_or_key) > -1
    found_key = @keys.indexOf(flag_or_key) > -1

    if found_flag
      fn?()
    else if found_key
      fn?(@args[flag_or_key])

  has_flag: (flag, strict=false) ->
    found_flag = flag

    if typeof flag == "object"
      for f in flag
        if !has_flag
          has_flag = @args.hasOwnProperty(f)

          if has_flag
            found_flag = f

    else
      has_flag = @args.hasOwnProperty(flag)

    return has_flag if !has_flag || (has_flag && !strict)
    @args[found_flag] == 1

  has_val: (key) ->
    @has_flag key

  val: (key) ->
    return if @args.hasOwnProperty(key)
      @args[key]
    else
      false

  arg_equals: (key, val) ->
    @val(key) == val

  data: -> @args

process_args = new NodeArgs()
process_start_time = (new Date).getTime()
process_end_time = 0

DEBUG_MODE = process_args.has_flag("--debug")

_debug = (msg) ->
  return unless DEBUG_MODE
  console.log colors.yellow msg

prompt.message = ">>>"
prompt.delimiter = " "

prompt.start()

quiz_modes = ["qa", "echo", "math"]
default_quiz_mode = "qa"
quiz_mode = if process_args.has_flag("--mode") 
  process_args.val("--mode")
else
  default_quiz_mode

if _.indexOf(quiz_modes, quiz_mode) < 0
  console.log colors.red "invalid quiz mode selected '#{quiz_mode}'; using default"
  quiz_mode = default_quiz_mode

if quiz_mode == "math"
  # at the end of setting up the math questions flip the mode back
  # to 'qa' for the interal testing
  # quiz_mode = "qa"
  how_many = 500 
  max_num = 19
  operators = ["+", "-"]

  # generate some math problems
  dictionary_data = for i in [0..how_many]
    operator = operators[Math.floor Math.random() * operators.length]
    num1 = Math.ceil Math.random() * max_num
    num2 = Math.ceil Math.random() * max_num
    problem = "#{num1} #{operator} #{num2}"
    answer = eval(problem)
    [problem, answer]

else
  dictionary_file = if process_args.has_val("--dictionary")
    "dictionaries/#{process_args.val('--dictionary')}.csv"
  else
    "dictionary.csv"

  _debug "selected dictionary: #{dictionary_file}"

  dictionary_data_raw = fs.readFileSync "#{__dirname}/#{dictionary_file}", "UTF-8"
  dictionary_data = for line in dictionary_data_raw.split("\n")
    if !_.isEmpty line
      _str.trim(word) for word in line.split(",")
    else
      null

  dictionary_data = _.reject dictionary_data, (w) => w == null || w == undefined

  _debug "loaded #{dictionary_data.length} total words"

# set to the index in the array which will be shown as the "question"
# the other index will be used as the answer
default_max_words = 999
shuffle_words = process_args.has_flag "--shuffle"
timed = process_args.has_flag "--timed"

invert_hints = false
randomly_invert_hints = false
max_words = if process_args.has_flag("--num_words") then parseInt(process_args.val("--num_words")) else default_max_words
words = if shuffle_words then _.shuffle(dictionary_data) else dictionary_data
prompts = []

if process_args.has_flag("--invert")
  if process_args.val("--invert") == "random"
    randomly_invert_hints = true
  else
    invert_hints = true

hint_idx = if invert_hints then 1 else 0
answer_idx = if invert_hints then 0 else 1

_debug("quiz mode is #{quiz_mode}")
_debug("shuffle is #{if shuffle_words then 'enabled' else ''}")
_debug("invert_hints is #{if invert_hints then 'enabled' else 'disabled'}")
_debug("randomly_invert_hints is #{if randomly_invert_hints then 'enabled' else 'disabled'}")
_debug("timed is #{if timed then 'enabled' else ''}")

if max_words < words.length
  words = _.first words, max_words
  console.log "#{max_words} words loaded! This is just a slice of the dictionary."
else
  console.log "#{words.length} words loaded! This is the entire dictionary."

for word, i in words
  invert_at_random = if randomly_invert_hints
    (Math.floor(Math.random() * 100)) % 2 == 0
  else
    false

  theprompt =
    name: "#{if invert_at_random then '-' else ''}word_#{i}"
    description: if invert_at_random then word[answer_idx] else word[hint_idx]

  prompts.push theprompt

score_results = (results) ->
  correct = 0
  wrong = 0
  score = 0
  wrong_indexes = []

  for key, guess of results
    idx = parseInt key.substr(key.indexOf("_") + 1)
    source = words[idx]
    inverted = key.charAt(0) == "-"

    switch quiz_mode
      when "qa"
        if (inverted && guess == source[hint_idx]) || (!inverted && guess == source[answer_idx])
          correct++
        else
          wrong++
          wrong_indexes.push idx

      when "echo"
        if guess == source[hint_idx]
          correct++
        else
          wrong++
          wrong_indexes.push idx

      when "math"
        if parseInt(guess) == source[answer_idx]
          correct++
        else
          wrong++
          wrong_indexes.push idx

  score = if correct == 0 then 0 else correct / (wrong + correct)

  wrong_words = []
  for i in wrong_indexes
    wrong_words.push words[i]

  _debug "score_results: score: #{score}, correct:#{correct}, wrong:#{wrong}"

  [score, correct, wrong, wrong_words]

process_setup_time = (new Date).getTime() - process_start_time

if process_setup_time < 1000
  process_setup_time = "<1"
else
  process_setup_time = process_setup_time / 1000
  
_debug("setup completed in #{process_setup_time} seconds")

prompt_start_time = (new Date).getTime()
prompt_end_time = 0

prompt.get prompts, (err, result) ->
  [score, correct, wrong, wrong_words] = score_results result

  prompt_end_time = (new Date).getTime()
  prompt_completion_time = (prompt_end_time - prompt_start_time) / 1000

  finished_msg = "You finished with a score of #{score * 100}%"

  if timed
    finished_msg += " in a time of #{prompt_completion_time} seconds"

  console.log colors.green finished_msg

  if wrong
    console.log colors.red "Looks like you need some more practice with the following:"

    for word, i in wrong_words
      switch quiz_mode
        when "qa" then console.log colors.red "#{i+1}. #{word[hint_idx]} - #{word[answer_idx]}"
        when "echo" then console.log colors.red "#{i+1}. #{word[hint_idx]}"
        when "math" then console.log colors.red "#{i+1}. #{word[hint_idx]} = #{word[answer_idx]}"

  process_end_time = (new Date).getTime()
  process_completion_time = (process_end_time - process_start_time) / 1000
  _debug("process completed in #{process_completion_time} seconds")
