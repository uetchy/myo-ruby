# myo-ruby

Connect to [Myo armband](https://www.thalmic.com/en/myo/) in Ruby

## Usage

You must start __Myo Connect.app__ first.

```ruby
require 'myo'

Myo.connect do |myo|
  myo.on :connected do
    puts "Myo connected!"
  end

  myo.on :pose do |pose, edge|
    puts "#{pose}: #{edge}"
  end

  myo.on :periodic do |orientation|
    puts orientation.accel.x
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'myo-ruby'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install myo-ruby
```

## Contributing

1. Fork it ( https://github.com/uetchy/myo-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
