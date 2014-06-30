require "stagger/version"

module Stagger
  SECONDS_IN_DAY = 86_400
  class << self
    def distribute(items, number_of_days)
      return [] if Array(items).empty? || number_of_days.to_i < 1
      time = get_starting_time
      period_in_seconds = get_period_in_seconds(items.size, number_of_days, time)
      items.reduce [] do |arr, item|
        if business_day?(time)
          arr << [item, time]
          time = time + period_in_seconds
          arr
        else
          time = time + SECONDS_IN_DAY
          redo
        end
      end
    end

    private

    def business_day?(time)
      if time.sunday? || time.saturday?
        false
      else
        time
      end
    end

    def get_starting_time
      tc = Time.now
      if tc.saturday?
        at_beginning_of_day(tc) + SECONDS_IN_DAY * 2
      elsif tc.sunday?
        at_beginning_of_day(tc) + SECONDS_IN_DAY
      else
        tc
      end
    end

    def get_period_in_seconds(items_size, number_of_days, starting_time)
      now = Time.now
      total_period = number_of_days * SECONDS_IN_DAY
      if business_day?(now)
        total_period -= (now - at_beginning_of_day(now))
      end
      total_period / items_size
    end

    def at_beginning_of_day(time)
      Time.new(time.year, time.month, time.day)
    end

    def at_end_of_day(time)
      at_beginning_of_day(time) + SECONDS_IN_DAY - 0.000000000001
    end
  end
end
