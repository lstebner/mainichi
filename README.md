# Vocab

What is this? Well, it's basically a deck of flashcards in the form of a console application. You run it, it asks you to translate a series of terms and then you get a grade! You could theoretically use it to test you in other departments, but I haven't gotten there quite yet.

## Dictionaries

This applications relies highly on the usage of "dictionaries". These are CSV files which contain a list of words and their translation seperated by a comma. These may contain more information in the future, but for now that is it.

When you run the app you tell it which dictionary to load. It then loads all the words in that dictionary and selects a subset (or uses them all) depending on configuration to quiz you. 

You can create any number of dictionaries you want, just add them to the "dictionaries" folder and when you start the app pass the name as the `--dictionary` value. 

## Running the Quiz

Running the quiz is easy, with node installed you just run this command:

```
node main.js
```

That's the vanilla version, which will run through all the words in 'dictionary.csv', in order. It prompts with the first index and wants the second index (the word after the comma) as answer. You'll likely want to configure this in various ways, so read below for configuration options.

## Configuring the Quiz

When starting up the quiz there are many configuration options that can be passed. Passing them looks something like this:

```
node main.js --num_words=10 --shuffle
```

The list of options and what they mean is below. All the options can stack with each other (unless otherwise noted) as seen in the example above.

    ### dictionary

    The default dictionary is `dictionary.csv` but you can also add dictionary files to the "dictionaries" folder and use them instead. To use one of these dictionaries, pass the name as a flag:

    ```
    node main.js --dictionary=japanese
    ```

    ### shuffle

    Since you'll probably get tired of the order of a dictionary quickly, the shuffle flag exists to switch things up. It doesn't need a value.

    ```
    node main.js --shuffle
    ```

    ### num_words

    Similar to why shuffle exists, but also because a dictionary can be pretty big; you may only want to use a subset of a dictionary in your quiz. The subset is random, but by passing num_words you can specify how many words to use. 

    ```
    node main.js --num_words=10
    ```

    ### debug

    Debug mode is mainly for myself, bug I will document it since it exists. It's a flag just like shuffle that outputs some extra information.

    ```
    node main.js --debug
    ```






