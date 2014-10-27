require 'spec_helper'
RSpec.describe Stagger do
  context 'distribute' do
    context 'invalid args' do
      it 'returns empty array when given empty array of items' do
        expect(Stagger.distribute([], 1)).to be_empty
      end

      it 'returns empty array when given nil for items' do
        expect(Stagger.distribute(nil, 1)).to be_empty
      end

      it 'returns empty array when given nil for days' do
        expect(Stagger.distribute([1], nil)).to be_empty
      end

      it 'returns empty array when given value that converts to number <1 for days' do
        expect(Stagger.distribute([1], 0)).to be_empty
        expect(Stagger.distribute([1], -1)).to be_empty
        expect(Stagger.distribute([1], 'hello')).to be_empty
      end
    end

    context 'valid args' do

      it 'returns same number of results as was given items' do
        expect(Stagger.distribute([1,2,3], 1).size).to eq(3)
      end

      it 'returns an array of arrays' do
        expect(Stagger.distribute([1,2,3], 1).first.class).to eq Array
      end

      it 'returns array of pairs where first pair item type is given item type and second is Time' do
        class Foo;end
        pair = Stagger.distribute([Foo.new], 1).first
        expect(pair.first).to be_a Foo
        expect(pair.last).to be_a Time
      end

      context 'single item' do
        it 'schedules immediately if today is a business day' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            pair = Stagger.distribute([1], 1).first
            expect(pair.last).to eq t
          end
        end

        it 'schedules to run after a delay if today is a business day' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            # stagger after a delay of 5 minutes
            pair = Stagger.distribute([1], 1, delay: 300).first
            expect(pair.last).to eq Time.local(2014, 6, 27, 18, 5)
          end
        end

        it 'schedules to run after a big delay that spans over the weekend' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            # stagger after a delay of 72 hours
            pair = Stagger.distribute([1], 1, delay: 72 * 60 * 60).first
            expect(pair.last).to eq Time.local(2014, 6, 30, 18)
          end
        end

        it 'schedules immediately if today is a business day and number of days > 1' do
          # a dumb test, actually, but I need to cover it
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            pair = Stagger.distribute([1], 2).first
            expect(pair.last).to eq t
          end
        end

        it 'schedules to run after a delay if today is a business day and number of days > 1' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            # stagger after a delay of 5 minutes
            pair = Stagger.distribute([1], 2, delay: 300).first
            expect(pair.last).to eq Time.local(2014, 6, 27, 18, 5)
          end
        end

        it 'schedules to run on Monday business day if delay will schedule the first item run on Saturday' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            # stagger after a delay of 7 hours
            pair = Stagger.distribute([1], 1, delay: 7 * 60 * 60).first
            expect(pair.last).to eq Time.local(2014, 6, 30) # Midnight, Monday
          end
        end

        it 'schedules to run on Monday business day if delay will schedule the first item run on Sunday' do
          t = Time.local(2014, 6, 27, 18) # 6pm, Friday
          Timecop.freeze(t) do
            # stagger after a delay of 31 hours (1 in the morning of Sunday)
            pair = Stagger.distribute([1], 1, delay: 31 * 60 * 60).first
            expect(pair.last).to eq Time.local(2014, 6, 30) # Midnight, Monday
          end
        end

        it 'schedules to run on Monday (00:00) if today is Sunday' do
          t = Time.local(2014, 6, 29, 14) # - 2pm, Sunday
          Timecop.freeze(t) do
            pair = Stagger.distribute([1], 1).first
            expect(pair.last).to eq Time.local(2014, 6, 30) # Midnight, Monday
          end
        end

        it 'schedules to run on Monday (00:00) if today is Saturday' do
          t = Time.local(2014, 6, 28, 14) # - 2pm, Saturday
          Timecop.freeze(t) do # - 2am, Friday
            pair = Stagger.distribute([1], 1).first
            expect(pair.last).to eq Time.local(2014, 6, 30) # Midnight, Monday
          end
        end
      end

      context 'multiple items' do
        context 'single day' do
          it 'schedules two items to run in a single day if  today is a business day' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 1)
              expect(results[0][0]).to eq(1)
              expect(results[0][1]).to eq(t)
              expect(results[1][0]).to eq(2)
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 19)
            end
          end

          it 'schedules two items to run in a single day if today is Saturday' do
            t = Time.local(2014, 6, 28, 14) # - 2pm, Saturday
            Timecop.freeze(t) do
              results = Stagger.distribute([1,2], 1)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 12) # Monday
            end
          end

          it 'schedules two items to run in a single day if today is Sunday' do
            t = Time.local(2014, 6, 29, 14) # - 2pm, Sunday
            Timecop.freeze(t) do
              results = Stagger.distribute([1,2], 1)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 12) # Monday
            end
          end

          it 'schedules three items to run in a single day if today is a business day' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 1)
              expect(results[0][0]).to eq(1)
              expect(results[0][1]).to eq(t)
              expect(results[1][0]).to eq(2)
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 17, 20)
              expect(results[2][0]).to eq(3)
              expect(results[2][1]).to eq Time.local(2014, 6, 27, 20, 40)
            end
          end

          it 'schedules three items to run in a single day of today is Saturday' do
            t = Time.local(2014, 6, 28, 14) # - 2pm, Saturday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 1)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 8) # Monday
              expect(results[2][1]).to eq Time.local(2014, 6, 30, 16) # Monday
            end
          end

          it 'schedules three items to run in a single day of today is Sunday' do
            t = Time.local(2014, 6, 29, 14) # - 2pm, Sunday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 1)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 8) # Monday
              expect(results[2][1]).to eq Time.local(2014, 6, 30, 16) # Monday
            end
          end

          it 'schedules many items to run in a single day if today is a business day' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute((1..100).to_a, 1)
              expect(results[0][0]).to eq(1)
              expect(results[0][1]).to eq(t)
              expect(results[1][0]).to eq(2)
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 14, 6) # every 6 mins
              expect(results[2][0]).to eq(3)
              expect(results[2][1]).to eq Time.local(2014, 6, 27, 14, 12) # every 6 mins
              expect(results[99][0]).to eq(100)
              expect(results[99][1]).to eq Time.local(2014, 6, 27, 23, 54)
            end
          end
        end

        context 'multiple days' do
          it 'schedules two items in two days if both days are business days' do
            t = Time.local(2014, 6, 26, 14) # - 2pm, Thursday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 2)
              expect(results[0][1]).to eq(t)
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 7)
            end
          end

          it 'schedules two items in two days if today is Friday' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 2)
              expect(results[0][1]).to eq Time.local(2014, 6, 27, 14) # Friday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 7) # Monday
            end
          end

          it 'schedules two items in two days if today is Saturday' do
            t = Time.local(2014, 6, 28, 14) # - 2pm, Saturday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 2)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 7, 1) # Tuesday
            end
          end

          it 'schedules two items in 3 days if all days are business days' do
            t = Time.local(2014, 6, 25, 14) # - 2pm, Wednesday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 3)
              expect(results[0][1]).to eq(t)
              expect(results[1][1]).to eq Time.local(2014, 6, 26, 19) # - 7 pm, Thursday
            end
          end

          it 'schedules two items in 3 days if today is Friday' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 3)
              expect(results[0][1]).to eq t
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 19) # Monday
            end
          end

          it 'schedules two items in 3 days if today is Saturday' do
            t = Time.local(2014, 6, 28, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2], 3)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday
              expect(results[1][1]).to eq Time.local(2014, 7, 1, 12) # Wednesday
            end
          end

          it 'schedules three items in two days if both days are business days' do
            t = Time.local(2014, 6, 26, 14) # - 2pm, Thursday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 2)
              expect(results[0][1]).to eq(t)
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 1, 20) # Friday
              expect(results[2][1]).to eq Time.local(2014, 6, 27, 12, 40) # Friday
            end
          end

          it 'schedules three items in two days if today is Friday' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 2)
              expect(results[0][1]).to eq(t) # Friday
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 1, 20) # Monday
              expect(results[2][1]).to eq Time.local(2014, 6, 30, 12, 40) # Monday
            end
          end

          it 'schedules three items in two days if today is Saturday' do
            t = Time.local(2014, 6, 28, 14) # - 2pm, Saturday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 2)
              expect(results[0][1]).to eq Time.local(2014, 6, 30) # Monday midnight
              expect(results[1][1]).to eq Time.local(2014, 6, 30, 16) # Monday 4pm
              expect(results[2][1]).to eq Time.local(2014, 7, 1, 8) # Tuesday 8 am
            end
          end

          it 'schedules many items in 30 days' do
            t = Time.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute((1..100).to_a, 30)
              expect(results[0][1]).to eq t
              expect(results[1][1]).to eq Time.local(2014, 6, 27, 21, 3, 36)
              expect(results[2][1]).to eq Time.local(2014, 6, 30, 4, 7, 12)
              expect(results[18][1]).to eq Time.local(2014, 7, 4, 21, 4, 48)
              expect(results[19][1]).to eq Time.local(2014, 7, 7, 4, 8, 24)
              expect(results[35][1]).to eq Time.local(2014, 7, 11, 21, 6)
              expect(results[99][1]).to eq Time.local(2014, 8, 7, 16, 56, 24)
            end
          end
        end

        context 'active support integration' do
          before do
            require 'active_support/all'
            Time.zone = 'Asia/Tokyo'
          end
          it 'returns ActiveSupport::TimeWithZone when ActiveSupport is available' do
            pair = Stagger.distribute([1], 1).first
            expect(pair.first).to eq(1)
            expect(pair.last).to be_a ::ActiveSupport::TimeWithZone
          end

          it 'schedules three items in two days if today is Friday' do
            t = Time.zone.local(2014, 6, 27, 14) # - 2pm, Friday
            Timecop.freeze(t) do
              results = Stagger.distribute([1, 2, 3], 2)
              expect(results[0][1]).to eq(t) # Friday
              expect(results[1][1]).to eq Time.zone.local(2014, 6, 30, 1, 20) # Monday
              expect(results[2][1]).to eq Time.zone.local(2014, 6, 30, 12, 40) # Monday
            end
          end
        end
      end
    end
  end
end

