# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


module Pokedex
  print  'Loading pokedex data...  '
  BASEPATH = File.expand_path(File.dirname(__FILE__))
  POKEMONDATA = JSON.parse(IO.readlines("#{BASEPATH}/ps-data/BattlePokedex.json")[0])
  FORMATSDATA = JSON.parse(IO.readlines("#{BASEPATH}/ps-data/BattleFormatsData.json")[0])
  MOVES = JSON.parse(IO.readlines("#{BASEPATH}/ps-data/BattleMovedex.json")[0])
  puts 'done.'
  
  def self.get_randbats_speeds
    # Adapted from https://github.com/Zarel/Pokemon-Showdown/blob/25c56a0293af58d20008a27f87186cecd1abba28/data/scripts.js#L1461
    level_scale = {
      'LC' => 95,
      'NFE' =>  90,
      'LC Uber' => 86,
      'NU' =>  86,
      'BL3' =>  84,
      'RU' =>  82,
      'BL2' =>  80,
      'UU' =>  78,
      'BL' =>  76,
      'Limbo' => 86,
      'Limbo C' => 83,
      'Limbo B' => 80,
      'Limbo A' => 77,
      'OU' =>  74,
      'CAP' =>  74,
      'Unreleased' =>  74,
      'Uber' =>  70
    }
    custom_scale = {
      # Really bad Pokemon and jokemons
      'Azurill' => 99, 'Burmy' => 99, 'Cascoon' => 99, 'Caterpie' => 99, 'Cleffa' => 99, 'Combee' => 99, 'Feebas' => 99, 'Igglybuff' => 99,
      'Happiny' => 99, 'Hoppip' => 99,'Kakuna' => 99, 'Kricketot' => 99, 'Ledyba' => 99, 'Magikarp' => 99, 'Metapod' => 99, 'Pichu' => 99, 
      'Ralts' => 99, 'Sentret' => 99, 'Shedinja' => 99, 'Silcoon' => 99, 'Slakoth' => 99, 'Sunkern' => 99, 'Tynamo' => 99, 'Tyrogue' => 99,
      'Unown' => 99, 'Weedle' => 99, 'Wurmple' => 99, 'Zigzagoon' => 99, 'Clefairy' => 95, 'Delibird' => 95, "Farfetch'd" => 95, 'Jigglypuff' => 95,
      'Kirlia' => 95, 'Ledian' => 95, 'Luvdisc' => 95, 'Marill' => 95, 'Skiploom' => 95, 'Pachirisu' => 90,

      # Eviolite
      'Ferroseed' => 95, 'Misdreavus' => 95, 'Munchlax' => 95, 'Murkrow' => 95, 'Natu' => 95,
      'Gligar' => 90, 'Metang' => 90, 'Monferno' => 90, 'Roselia' => 90, 'Seadra' => 90, 'Togetic' => 90, 'Wartortle' => 90, 'Whirlipede' => 90,
      'Dusclops' => 84, 'Porygon2' => 82, 'Chansey' => 78,

      # Weather or teammate dependent
      'Snover' => 95, 'Vulpix' => 95, 'Ninetales' => 78, 'Tentacruel' => 78, 'Toxicroak' => 78,

      # Banned mega
      'Kangaskhan' => 72, 'Gengar' => 72, 'Blaziken' => 72,

      # Holistic judgment
      'Carvanha' => 90, 'Lucario' => 72, 'Genesect' => 72, 'Kyurem' => 78
    }
    # end adapted code
    
    rand_speeds = {}
    POKEMONDATA.each do |name, data|
      fd = FORMATSDATA[name] || next
      
      realname = data["species"]
      tier = fd["tier"]
      
      level = custom_scale[realname] || level_scale[tier] || next
      base_speed = data["baseStats"]["spe"]
      rand_speeds[name] = ((31 + 2*base_speed + 85/4) * level.to_f/100 + 5).to_i
      
    end
    
    rand_speeds
    
  end
  
  print "Loading randbats data...  "
  RANDBATS_SPEEDS = get_randbats_speeds
  puts "done."
end
