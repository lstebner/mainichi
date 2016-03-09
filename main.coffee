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

DEBUG_MODE = process_args.has_flag("--debug")

_debug = (msg) ->
  return unless DEBUG_MODE
  console.log colors.yellow msg

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

prompt.message = ">>>"
prompt.delimiter = " "

prompt.start()

# set to the index in the array which will be shown as the "question"
# the other index will be used as the answer
hint_idx = 0
answer_idx = 1
default_max_words = 999
shuffle_words = process_args.has_flag "--shuffle"
max_words = if process_args.has_flag("--num_words") then parseInt(process_args.val("--num_words")) else default_max_words
words = if shuffle_words then _.shuffle(dictionary_data) else dictionary_data
prompts = []

_debug("shuffle enabled") if shuffle_words

if max_words < words.length
  words = _.first words, max_words
  console.log "#{max_words} words loaded! This is just a slice of the dictionary."
else
  console.log "#{words.length} words loaded! This is the entire dictionary."

for word, i in words
  theprompt =
    name: "word_#{i}"
    description: word[hint_idx]

  prompts.push theprompt

score_results = (results) ->
  correct = 0
  wrong = 0
  score = 0
  wrong_indexes = []

  for key, guess of results
    idx = parseInt key.substr(key.indexOf("_") + 1)
    source = words[idx]

    if guess == source[answer_idx]
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

prompt.get prompts, (err, result) ->
  [score, correct, wrong, wrong_words] = score_results result

  console.log colors.green "You finished with a score of #{score * 100}%"

  if wrong
    console.log colors.red "Looks like you need some more practice with the following words:"

    for word, i in wrong_words
      console.log colors.red "#{i+1}. #{word[hint_idx]} - #{word[answer_idx]}"
