# Introduction

[Pokemon Showdown][0] chat needs some features, so this supplements it by running a bot that responds to some commands in the chat or pms it recieves.

  [0]: http://pokemonshowdown.com

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

 
# Usage

   
    ruby connector.rb USER PASS ROOM


