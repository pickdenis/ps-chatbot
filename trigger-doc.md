# Triggers

The basic structure of a trigger is this:

```ruby
Trigger.new do |t|
  t.match { |info|
    # checks
  }
  
  t.act { |info|
    # if those checks pass
  }
end
```


The info object is passed from the chat handler. It will be a hash that maps the following symbols
```ruby
{
  :who => ... # name of the user who chatted
  :where => ... # 'c' if it was in a main chat or 'pm' if it was in a PM
  :room => ... # the room the chat occured in (only relevant for 'c')
  :what => ... # the message the user sent
  :ws => ... # the websocket client object. (you won't need this in a match block)
}
  
```

Here's an example from a version of the stat calculator:

```ruby
t.match { |info|
  info[:what][0..3] == 'base' &&
  info[:what].scan(/[:\+\-\w]+/)
}
```

First, it checks if the message starts with `'base'`. If it does, then it returns a scan of each "flag" from the text. (for example, `base:40 +5` becomes `["base:40", "+5"]`) 

A match that would only respond to a certain person would look like this:

```ruby
t.match { |info|
  info[:what][0..3] == 'base' &&
  info[:who] == 'person' &&
  info[:what].scan(/[:\+\-\w]+/)
}
```

# Actions

Once the match has been performed and returns a value other than `false` or `nil`, this gets added to the info hash under the key `:result`

Another key is added, `:respond`, and this is used to send a message back. If `info[:where] == 'pm'` then it will respond to the sender, and if `info[:where] == 'c'`, it will respond in `info[:room]`.
