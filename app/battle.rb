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
    JSON.parse(message[2])["challengesFrom"].each do |who, data|
      if data["format"] == "challengecup1vs1"
        ws.send("|/utm {}")
        ws.send("|/accept #{who}, {}")
      end
    end
    
  end
  
end

class BattleAdapter
  attr_accessor :battle, :respond, :id
  
  def initialize args
    @id = args[:id]
    @battle = Battle.new id: @id # Battle object
    @respond = args[:respond] # This should be passed from the ChatHandler
  end
  
  def respond message
    @respond.call(message)
  end
  
  def handle message # message is already split by |
    case message[0]
    when 'poke'
      # for now, this stuff doesn't matter
    when 'request'
      data = JSON.parse(message[1])["side"]
      player = data["id"]
      # battle
      @battle.send(player)
    when 'win'
      respond('/leave')
    end
  end
end

class Battle # Hold the logical state of the battle
  attr_accessor :id, :p1, :p2
  
  def initialize args
    @id = args[:id]
    
    # These will be populated as data is sent
    
    @p1 = Player.new
    @p2 = Player.new
    
  end
  
  def add_to_team player, poke
    player.team << poke
  end
  
  def move
    
  end
  
  def switch
    
  end
  
  def status
    
  end
end

class Player
  attr_accessor :name, :team, :active_poke
end

class Pokemon
  attr_accessor :ident, :details, :condition, :active, :base_ability, :moves, :item, :can_mega_evo
  
  def initialize args
    @ident = args[:ident]
    @details = args[:details]
    @condition = args[:condition]
    @active = args[:active]
    @bsae_ability = args[:base_ability]
    @moves = args[:moves]
    @item = args[:item]
    @can_mega_evo = args[:can_mega_evo]
  end
end

class BattleLogic
  def turn
    
  end
end