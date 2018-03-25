# MethodPattern

Pattern matching for Ruby methods

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'method_pattern'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install method_pattern

## Usage

Extend any class you want to be able to use pattern matching with the `MethodPattern` module:

```ruby
class HandleResponse
  extend MethodPattern
end
```

Then you can define your method with `defn`:

```ruby
class HandleResponse
  extend MethodPattern

  defn :call do
    # ...
  end
end
```

Inside of your `defn` block, you declare your argument patterns using `with`:

```ruby
class Fibonnaci
  extend MethodPattern

  defn :call do
    with(0..1) { |n| n }
    with(Integer) { |n| call(n - 1) + call(n - 2) }
  end
end
```

This example will handle 0 and 1 as special cases and all other integers are funneled into the second implementation. Patterns declared higher take precedence.

Notice that we could pass in a class or even a range for our pattern. There are several things we can use:

- Strings: `with('hello') { |str| ... }` matches an exact string
- Numbers: `with(15) { |num| ... }` matches an exact number
- Symbol: `with(:foo) { |sym| ... }` matches a particular symbol
- Class: `with(Integer) { |num| ... }` matches any instance of the given class
- Regex: `with(/foo/) { |str| ... }` matches any string that matches the regex
- Range: `with(0...10) { |num| ... }` matches any value covered by the range
- Proc/lambda: `with(-> n { n > 3 }) { |n| ... }` matches if the proc returns a truthy value

Note that the method arguments are passed to the block. This lets the block become the method body.

### It's not just for single arguments

You can pass multiple patterns to `with` and it will match them in order:

```ruby
defn :baz do
  with('foo', /bar/) { |a, b| a + b }
end
```

### Keyword arguments

Keyword arguments work, too:

```ruby
class HandleResponse
  extend MethodPattern

  defn :call do
    with status: 200...300, headers: { 'Content-Type': /json/ } do |body:, **|
      JSON.parse(body, symbolize_names: true)
    end

    # All 4xx and 5xx responses are errors
    with(status: 400..599) { |body:, **| ErrorResponse.call body }
  end
end
```

### Caveats

Unfortunately, because `with` accepts its own block, you cannot match on whether a block was passed to the method.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jgaskins/method_pattern. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MethodPattern project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jgaskins/method_pattern/blob/master/CODE_OF_CONDUCT.md).
