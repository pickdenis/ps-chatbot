class BattleHandler
  attr_accessor :battles, :ws
  
  def initialize
    @battles = {}
  end
  
  def new_battle id, ws
    respond = proc do |message| ws.send("#{ id }|#{ message }") end
    adapter = BattleAdapter.new id: id, respond: respond
    @battles[id] = adapter
  end
  
  def handle message, ws # message is already split by |
    
    b_id = message.shift[1..-2]
    
    # if this is a new battle
    if !@battles[b_id]
      new_battle(b_id, ws)
    end
    
    if message[0][0] != '|'
      message[0] = '|' + message[0]
    end
    
    
    message.join('|').split("\n").each do |part|
      if part != '|'
        @battles[b_id].handle(part.split('|')[1..-1])
      end
    end
  end
  
  def handle_challenge message, ws
    JSON.parse(message[2])["challengesFrom"].each do |who, format|
      if format == "challengecup1vs1"
        ws.send("|/utm {}")
        ws.send("|/accept #{who}, {}")
      end
    end
    
  end
  
  def self.parse_battle_id id
    parts = id.split('-')
    
    # battle-format-number
    parts.shift # throw away the first prat
    
    { format: parts.shift, number: parts.shift}
  end
  
  def self.parse_poke_details details
    parts = details.split(', ')
    
    { species: parts.shift.gsub('-*', ''), level: parts.shift[1..-1], gender: parts.shift }
  end
  
  def battle_loop format, ws
    EM::PeriodicTimer.new(30) do
      ws.send("|/search #{format}")
    end
  end
  
end

class BattleAdapter
  attr_accessor :battle, :respond, :id, :rqid
  
  def initialize args
    @id = args[:id]
    format = BattleHandler.parse_battle_id(@id)[:format]
    
    # If the format is not recognized, it will try to use the default logic, which throws
    # an exception with every method. Only accept battles that have logic
    logic = ({'challengecup1vs1' => CC1vs1Logic}[format] || BattleLogic).new
    
    
    @battle = Battle.new id: @id, logic: logic # Battle object
    @respond = args[:respond] # This should be passed from the ChatHandler
  end
  
  def respond message
    @respond.call(message)
  end
  
  def handle message # message is already split by |
    case message[0]
    when 'init'
      respond('/timer')
    when 'poke'
      whose = message[1]
      details = BattleHandler.parse_poke_details(message[2])
      ident = "#{whose}: #{details[:species]}"
      
      p_object = @battle.send(whose)
      p_object.team ||= {}
      p_object.team[ident] ||= details[:species]
    when 'switch'
      switched = message[1]
      who = switched[0..1]
      species = switched[5..-1]
      
      if species == 'Floette-Eternal-Flow'
        species = 'Floette-Eternal-Flower'
      end
      
      @battle.send(who).side ||= species
    when 'request'
      request = JSON.parse(message[1])
      @rqid = request['rqid']
      
      sidedata = request['side']
      player = sidedata['id']
      
      # let the Battle object know who it's controlling
      @battle.set_me(player)
      
      # set the data
      p_object = @battle.send(player)
      p_object.name = sidedata[:name]
      p_object.team ||= {}
      
      p_object.side = []
      sidedata['pokemon'].each_with_index do |poke, index|
        poke_object = Pokemon.new(
            ident: poke['ident'], details: poke['details'],condition: poke['condition'], active: poke['active'],
            stats: poke['stats'], moves: poke['moves'],base_ability: poke['baseability'], item: poke['item'],
            can_mega_evo: poke['canmegaevo'])
        
        p_object.team[poke['ident']] = poke_object
        p_object.side << if request['active']
          
          {object: poke_object, moves: request['active'][index]['moves']}
        else
          {object: poke_object}
        end
        
      end
      
    when 'teampreview'
      respond(@battle.logic.chooselead(@rqid))
    when 'turn'
      respond(@battle.logic.move(@rqid))
    when 'win', 'tie'
      if (message[1] == $login[:name])
        respond('git gud')
      else
        respond('ok')
      end
      
      respond('/leave')
    end
  end
end

class Battle # Hold the logical state of the battle
  attr_accessor :id, :p1, :p2, :logic
  
  def initialize args
    @id = args[:id]
    
    # These will be populated as data is sent
    
    @p1 = Player.new
    @p2 = Player.new
    
    @logic = args[:logic]
    
    
  end
  
  
  def add_to_team player, poke
    player.team << poke
  end
  
  def set_me id
    if id == 'p1'
      @logic.me = @p1
      @logic.other = @p2
    else
      @logic.me = @p2
      @logic.other = @p1
    end
  end
end

class Player
  attr_accessor :name, :team, :side
  
  def initialize *argv
    @name, @team = argv
  end
end

class Pokemon
  attr_accessor :ident, :details, :condition, :active, :base_ability, :moves, :item, :can_mega_evo
  
  def initialize args
    @ident = args[:ident]
    @details = args[:details]
    @condition = args[:condition]
    @active = args[:active]
    @base_ability = args[:base_ability]
    @moves = args[:moves]
    @item = args[:item]
    @can_mega_evo = args[:can_mega_evo]
  end
end

class BattleLogic
  attr_accessor :me, :other
  
  def initialize *argv
    @me, @other = argv
  end
  
  def move rqid
    throw NotImplementedError
  end
  
  def chooselead rqid
    throw NotImplementedError
  end
  
  def switch rqid
    throw NotImplementedError
  end
end

require_relative 'battleutil/cc1vs1helper.rb'

class CC1vs1Logic < BattleLogic
  def chooselead rqid
    
    best = @me.team.values.max_by do |poke|
      if poke == 'Floette-Eternal-Flower'
        0
      else
        species = BattleHandler.parse_poke_details(poke.details)[:species]
        
        
        poke.moves.map { |move| CC1vs1.calculate_move_score(species, move, @other.team.values) }.reduce(:+)
      end
    end
    
    bestmonindex = @me.team.values.index(best) + 1
    
    rest = (1..6).to_a
    rest.unshift(rest.delete(bestmonindex))
    
    "/team #{rest.join('')}|#{rqid}"
    
  end
  
  def move rqid
    
    moves = @me.side.first[:moves].select { |move| !move['disabled'] }.map { |o| o['id'] }
    otherside = [@other.side] # put it in an array because calculate_move_score takes an array
    my_species = BattleHandler.parse_poke_details(@me.side.first[:object].details)[:species]
    
    
    chosen = moves.max_by { |move| CC1vs1.calculate_move_score(my_species, move, otherside) }
    
    "/choose move #{chosen}|#{rqid}"
  end
end