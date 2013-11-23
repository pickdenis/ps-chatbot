Triggers:

The basic structure of a triggers is this:

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
