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
      :tried_all_tactics
    end

    def b(n)
      BoxedFixNum.new n
    end
  end
end

class Sorter
  def self.stable(items)
    items.sort
  end
end

t = Theft::Runner.new autosize: true

property_sorting_should_be_stable = lambda do |generated_arg| # , other_generated_arg, etc 
  sorted = Sorter.stable(generated_arg)

  # fail if even
  sorted.size % 2 == 0 ? :fail : :pass
end

config = {
  description: "sorting should be stable",
  property: property_sorting_should_be_stable,
  arg_descriptors: [BoxedFixNumArgDescriptor],
  trials: 60,
  # must_have_seeds: [],
  # seed: nil,
  progress: lambda{|trial_num, args, status| STDOUT.write '.' if trial_num % 2 == 0 },
  env: :whatevs
}

t.run config


# FOR EACH ARGUMENT TO THE FUNCTION UNDER TEST
  # setup - returns instance of TheftInput
  # teardown - cleanup (prob not needed)
  # hash - same input should hash the same regardless of object identity
  # print - print out the inputs when they fail
  # shrink - find subset of failing input (cut array in half, pop off the end, etc)

