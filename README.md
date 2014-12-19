# Myo

Connect to Myo armband in Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'myo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install myo-ruby

## Example

You should start __Myo Connect.app__ first.

```ruby
Myo.connect do |myo|
  myo.on :connected do
    puts "Myo connected!"
  end

  myo.on :pose do |m, pose, edge|
    puts "#{pose}: #{edge}"
  end

  myo.on :periodic do |m, orientation|
    puts orientation.accel.x
  end
end
```

## Contributing

1. Fork it ( https://github.com/uetchy/myo.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
