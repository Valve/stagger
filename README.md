# Stagger

[![Build Status](https://travis-ci.org/Valve/stagger.svg?branch=master)](https://travis-ci.org/Valve/stagger)
[![Gem Version](https://badge.fury.io/rb/stagger.svg)](http://badge.fury.io/rb/stagger)
[![Code Climate](https://codeclimate.com/github/Valve/stagger.png)](https://codeclimate.com/github/Valve/stagger)

Stagger is a simple gem that evenly distributes items across business
days.
On the surface, this tasks seems simple, but when you have a lot of
tasks,
that should be scheduled across business days, that span several weeks,
it gets complicated. When you have both plain ruby `Time` and
`ActiveSupport::TimeWithZone`, it gets even more hairy.

Stagger has good test coverage, I covered all cases
I could think of with specs.

Stagger has no runtime dependencies.

**Real life business cases**:

> Schedule 100 emails to be distributed evenly across next 14 business days:

```ruby
emails = get_emails()
schedule = Stagger.distribute(emails, 14)
```

> Schedule one item to be sent as soon as possible but on a business day only:

```ruby
email = get_email() # only one email
schedule = Stagger.distribute([email], 1)
business day
```

> Schedule one item to be sent after a delay of 5 minutes, but on a business day only:

```ruby
email = get_email() # only one email
# specify delay in seconds
schedule = Stagger.distribute([email], 1, delay: 5 * 60)
```

> Schedule 1000 emails to be sent across next 30 business days:

```ruby
emails = get_emails()
schedule = Stagger.distribute(emails, 30)
```

`schedule` is an array of arrays, each item is a pair of original item, associated with `Time`:

```ruby
Time.now # 2014-06-27 14:00:00 +0400
# 3 items will be distributed today
schedule = Stagger.distribute([1,2,3], 1)
=> # [[1, 2014-6-27 14:00:00], [2, 2014-6-27 17:20:00], [3, 2014-6-27 20:40:00]]
```

First item is scheduled as soon as possible (after an optional delay), while the rest is
distributed evenly across business days.

## Rails integration

Since this gem has no dependencies, it returns instances of ruby `Time`.
But when `ActiveSupport` is available, it returns instances of rails'
`ActiveSupport::TimeWithZone` with your current timezone already set.
In other words, you don't need to do anything when using this gem with
Rails.

## Options

### Delay

Specified in seconds, default is 0.

Will make the first and subsequent items to be shifted ahead in time.
Useful in the scenarios when the first item without an initial delay will
have been in the past by the time the processing logic picks it up.
If the delay makes the first item to be scheduled on a weekend, it will
be sent on Monday at 00 hours.

## Plans

Plans to add support for holidays and working hours in the future.**


## Installation

Add this line to your application's Gemfile:

    gem 'stagger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stagger

### Compatibility

This gem is tested against MRI 2.1.x on Travis CI

## Contributing

1. Fork it ( https://github.com/[my-github-username]/stagger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Make sure you run tests with `rspec` command
