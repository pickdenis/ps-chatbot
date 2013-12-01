# Introduction

[Pokemon Showdown][0] chat needs some features, so this supplements it by running a bot that responds to some commands in the chat or pms it recieves. If you would like to contribute, check the [Wiki][1]

  [0]: http://pokemonshowdown.com
  [1]: https://github.com/pickdenis/ps-chatbot/wiki

# Features

## Stat calculator
The stat calculator can do these things:
  1. calculate final stat from base stat and evs
  2. calculate effective base stat after boosts/modifiers
    * currently supported modifiers: scarf, doubled

### Examples

The bot will respond to any command starting with `base:number`: 

    base:120 invested 
    base:105 invested doubled asbase       (Mega-Mawile's base attack)
    base:80 invested scarf asbase          (Effective base of 80 scarfed mon)

# Installation

Note: If you have `faye-websocket` and `eventmachine` installed, you can skip this step.

    bundle install

Alternatively, you can `gem install` everything you see in the `Gemfile`.

# Usage

   
    ruby connector.rb USER PASS ROOM

# Contact

Pull requests are encouraged. Feel free to submit one if you notice something is wrong or have a cool feature to add.

You can contact me at pickmydenis@gmail.com or pm 'pick' on Pokemon Showdown if I'm online.
