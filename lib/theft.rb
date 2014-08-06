require_relative "theft/version"
require 'set'

module Theft
  class Runner
    def initialize(args={})
      @auto_size = true
      @evaluated_inputs = Set.new
    end

    def run(config)
      @seed = config[:seed] || Time.now.to_i
      @rng = Random.new(@seed)
      puts "seed: #{@seed}"

      @trials = config[:trials] || 100

      property = config[:property]

      fails = 0
      passes = 0
      @trials.times do |trial_num|
        @descriptors = config[:arg_descriptors]
        args = @descriptors.map do |desc|
          desc.setup(@rng, config[:env])
        end

        unless has_been_tried?(@descriptors, args)
          result = property.call(*args)

          case result
          when :fail
            fails += 1

            args = try_to_shrink(args, property)

            puts "failed on trial: #{trial_num}"
            @descriptors.each.with_index do |desc, i|
              puts desc.to_s(args[i])
            end
          when :passes
            passes += 1
          end

          config[:progress].call(trial_num, args, :passing_for_now)
        end
      end

      puts
      puts "FAILS: #{fails}"
      puts "PASSES: #{passes}"
    end

    def try_to_shrink(args, property)
      # until :tried_all_tactics ...
      args
    end

    def has_been_tried?(descriptors, args)
      @evaluated_inputs.include? hash_inputs(descriptors, args)
    end

    def hash_inputs(descriptors, args)
      hashes = descriptors.map.with_index do |desc, i|
        desc.hash(args[i])
      end
      hash = Digest::MD5.new.digest hashes.join(",")
      @evaluated_inputs << hash
    end
  end
end
