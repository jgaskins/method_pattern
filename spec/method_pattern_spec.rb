require 'method_pattern'
require 'json'

c = Class.new do
  extend MethodPattern

  def initialize
    @zomg = 'lol'
  end

  defn :foo do
    with(123) { @zomg }
    with(/lo+l/) { 'LMAO' }
    with('a', /b/) { |a, b| a + b }
    with(String) { |str| str.upcase }
    with status: 200...300, headers: { 'Content-Type': /json/ } do |body:, **|
      JSON.parse(body, symbolize_names: true)
    end
    with status: 404, headers: { 'Content-Type': /json/ } do
      'Not found'
    end
    with(->x { x > 3 }) { |x| x * 3 }
  end

  defn :factorial do
    with(1) { 1 }
    with(Integer) { |n| n * factorial(n - 1) }
  end

  defn :fibonacci do
    with(0..1) { |n| n }
    with(-> n { n.positive? }) { |n| fibonacci(n - 1) + fibonacci(n - 2) }
  end
end

RSpec.describe MethodPattern do
  describe 'pattern matching' do
    let(:o) { c.new }

    it 'allows recursion' do
      expect(o.factorial(1)).to eq 1
      expect(o.factorial(2)).to eq 2
      expect(o.factorial(3)).to eq 6
      expect(o.factorial(4)).to eq 24
      expect(o.factorial(5)).to eq 120

      expect(o.fibonacci(0)).to eq 0
      expect(o.fibonacci(1)).to eq 1
      expect(o.fibonacci(2)).to eq 1
      expect(o.fibonacci(3)).to eq 2
      expect(o.fibonacci(4)).to eq 3
      expect { o.fibonacci -1 }.to raise_error ArgumentError
    end
    it 'matches procs' do
      expect(o.foo(4)).to eq 12
    end
    it 'matches numbers' do
      expect(o.foo(123)).to eq 'lol'
    end
    it 'matches a string value' do
      expect(o.foo('zomg')).to eq 'ZOMG'
    end
    it 'matches a string regex pattern' do
      expect(o.foo('looool')).to eq 'LMAO'
    end
    it 'matches multiple arguments' do
      expect(o.foo('a', 'b')).to eq 'ab'
    end
    it 'matches recursive patterns on hash keys/values' do
      expect(o.foo(
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': 1234,
        },
        body: { foo: 'bar' }.to_json,
      )).to eq(foo: 'bar')
      expect(o.foo(
        status: 404,
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': 1234,
        },
      )).to eq 'Not found'
    end

    it 'raises an ArgumentError if no patterns match' do
      expect { o.foo(:bar, 'baz', 123, ['lol']) }
        .to raise_error(ArgumentError)
    end
  end
end
