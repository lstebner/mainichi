# Mainichi (まいにち)

What is this? 

Mainichi translates to "everyday". The idea behind this application is to be able to quickly practice small excercises which keep your brain refreshed. These can also help you wake up, or even just get your fingers warmed up. 

The initial purpose was actually to create a question and answer quiz to review like flash cards. I wanted to use this to practice Japanese words, but could see many other use cases for it. So far, I've dabbled in a few (math, typing warmup) and have a few others in mind. I think this is great for a language learning tool though and would love to see more dictionaries added for other languages.

## Installation

The first time you get this repo you need to run an installation. If you have node and npm ready to go, it's easy, just `cd` into the same directory this readme is in and run

```
npm install
```

If all goes well, you're set. If there are errors, fix them (nothing should go wrong). Next, do the compile step below.

## Compiling

The code ships with a main entry point of `quiz.coffee` but you need to compile it into a regular javascript file. If you don't have coffeescript installed, `npm install --save coffee` and then run the following command.

```
coffee -c quiz.coffee
```

Now you're really, really, ready to run the app!

## Dictionaries

This application relies highly on the usage of "dictionaries". These are CSV files which contain a list of words and their translation seperated by a comma (content may vary, depending on dictionary). These may contain more information in the future, but for now that is it.

When you run the app you tell it which dictionary to load. It then loads all the words in that dictionary and selects a subset (or uses them all) depending on your configuration to quiz you. 

You can create any number of dictionaries you want, just add them to the "dictionaries" folder and when you start the app pass the name as the `--dictionary` value. 

## Running the Quiz

Running the quiz is easy, with node installed you just run this command:

```
node quiz.js
```

That's the vanilla version, which will run through all the words in 'dictionary.csv', in order. It prompts with the first index and expects the second index (the word after the comma) as the answer. You'll likely want to configure this in various ways, so read below for configuration options.

## Configuring the Quiz

When starting up the quiz there are many configuration options that can be passed. Passing them looks something like this:

```
node quiz.js --num_words=20 --shuffle --timed --dictionary=japanese-hiragana
```

The list of options and what they mean is below. All the options can stack with each other (unless otherwise noted) as seen in the example above.

    ### dictionary

    The default dictionary is `dictionary.csv` but you can also add dictionary files to the "dictionaries" folder and use them instead. To use one of these dictionaries, pass the name as a flag:

    ```
    node quiz.js --dictionary=japanese
    ```

    ### shuffle

    Since you'll probably get tired of the order of a dictionary quickly, the shuffle flag exists to switch things up. It doesn't need a value.

    ```
    node quiz.js --shuffle
    ```

    ### num_words

    Similar to why shuffle exists, but also because a dictionary can be pretty big; you may only want to use a subset of a dictionary in your quiz. The subset is random, but by passing num_words you can specify how many words to use. 

    ```
    node quiz.js --num_words=10
    ```

    ### mode

    Quiz mode is a feature which alters the type of quiz you want to take. The default mode is called "qa" which stands for "Question and Answer". In this form, the quiz is formatted to prompt with a "question" and expects the user to input the "answer". This is the mode the "invert" option most applies to in the sense that it flips which value is used for the prompts.

    The second mode that exists is called "echo". In this mode, the user is meant to echo the words that are shown as the prompt. Some of the dictionaries intended for this mode are actually intended to be typing warmups so they just contain words or even sentences. You could also use the 'qa' dictionaries and even the 'invert' flag to practice words from there. 

    The third mode is "math". For this mode you still pass in a dictionary which contains the math problems you want to be quizzed on (read about the Generator if you're thinking creating a file of math problems sounds terrible), but you still tell it to use the mode "math" so that it knows check your answers correctly.

    ```
    //echo mode with homophones
    node quiz.js --mode=echo --dictionary=english-homophones

    //basic math
    node quiz.js --mode=math --dictionary=basic_math_easy --shuffle --timed
    ```

    ### debug

    Debug mode is mainly for myself, bug I will document it since it exists. It's a flag just like shuffle that outputs some extra information.

    ```
    node quiz.js --debug
    ```

    ### invert

    Inverting gives you the "answers" as the "hints", aka the opposite of normal order is used from the dictionary. You can also invert at random if you like variety. 

    To invert everything in the quiz:

    ```
    node quiz.js --invert
    ```

    To invert at random...

    ```
    node quiz.js --invert=random
    ```

    ### timed

    To time your test, pass the `timed` flag. It will then let you know how long you took to complete the quiz. 

    ```
    node quiz.js --timed
    ```


## Generator

Another piece of code has been introduced to this project which is called the "generator". This is intended to assist in creating dictionaries that can be automatically created. The prime example here is math, since we want a lot of problems at random and we might want new ones every now and then. 

The Generator actually consists of a main class and then subclasses which contain specific generator logic. You can make more of these easily, or just use the ones that are provided. Either way, compiling and running the generator is very similar to the quiz itself. After it runs you'll have a knew dictionary which can be loaded into the quiz.

    ### compiling

    You'll need to one time compile the generator before you use it and again if you add any new generators to it. It's easy though so don't sweat it.

    ```
    coffee -cb generate.coffee
    ````

    ### Generatin'

    Once you've got a compiled version of the generate you can quickly generate yourself lots of math problems. Doing so would look a bit like this:

    ```
    node generate.js --dictionary=basic_math
    ```

    Running this command would then run the generated mapped to the key "basic_math" and tell you about the file it created at the end. The file is timestamped for safety so you should renamed it afterwards if you are satisfied with the result. You can then load these into the quiz as the 'dictionary' option. 

    There is more to learn about generators! But I have to write up about it and maybe even do some cleanup first so look forward to that coming in the future. For now, this should suffice!





