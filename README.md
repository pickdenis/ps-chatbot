# Introduction

[Pokemon Showdown][0] chat needs some features, so this supplements it by running a bot that responds to some commands in the chat.

  [0]: http://pokemonshowdown.com

# Features

## Triggers
The stat calculator can do these things:
  1. calculate final stat from base stat and evs
  2. calculate effective base stat after boosts/modifiers
    * currently supported modifiers: scarf, doubled

### Examples

The bot will respond to any command starting with `base:number`: 

    base:120 invested 
    base:105 invested doubled asbase       (Mega-Mawile's base attack)
    base:80 invested scarf asbase          (Effective base of 80 scarfed mon)



# Usage

    ruby connector.rb USER PASS ROOM


