require 'digest'
require_relative '../lib/theft'

class BoxedFixNum
  attr_reader :n
  def initialize(n)
    @n = n
  end

  def <=>(other)
    @n <=> other.n
  end
end

class BoxedFixNumArgDescriptor
  class << self
    def setup(rng, args={})
      [].tap do |ar|
        rng.rand(0..100).times do |i|
          ar << b(rng.rand(0..2000))
        end
      end
    end

    def teardown(list)
      # do stuff
    end

    def hash(list)
      Digest::MD5.new.digest to_s(list)
    end

    def to_s(list)
      "[#{list.size}] " + list.map(&:n).map(&:to_s).join(",")
    end

    def shrink(list, tactic)
      size = list.size
      if size < 2
        puts "#shrink .. dead end"
        return :dead_end 
      end
      case tactic
      when 0
        return list[0..size/2]
      when 1
        return list[size/2..-1]
      when 2
        return list[1..-1]
      when 3
        return list[0..-2]
      when 4
        return list[0..-2]
      end

      return :tried_all_tactics
    end

    def b(n)
      BoxedFixNum.new n
    end
  end
end

class Sorter
  def self.sort(items)
    unstable items
    # stable items
  end

  def self.stable(items)
    items.sort_by.with_index { |x, idx| [x, idx] }
  end

  def self.unstable(items)
    items.sort
  end
end

t = Theft::Runner.new autosize: true

property_sorting_should_be_stable = lambda do |generated_arg| # , other_generated_arg, etc 
  sorted = Sorter.sort(generated_arg)

  sorted.chunk{|item| item.n}.each do |n, items|
    if items.size > 1
      # lazily spot check
      first = items.first
      last = items.last

      if generated_arg.index(first) > generated_arg.index(last)
        return :fail unless sorted.index(first) > sorted.index(last)
      else
        return :fail unless sorted.index(first) < sorted.index(last)
      end
    end
  end

  :pass
end

config = {
  description: "sorting should be stable",
  property: property_sorting_should_be_stable,
  arg_descriptors: [BoxedFixNumArgDescriptor],
  trials: 3,
  # must_have_seeds: [],
  # seed: nil,
  progress: lambda{|trial_num, args, status| STDOUT.write '.' if trial_num % 2 == 0 },
  env: :whatevs
}

t.run config
