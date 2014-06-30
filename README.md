# Stagger

[![Build Status](https://travis-ci.org/Valve/stagger.svg?branch=master)](https://travis-ci.org/Valve/stagger)

Stagger is a simple gem that evenly distributes items across business
days.
On the surface, this tasks seems simple, but when you have a lot of
tasks,
that should be scheduled across business days, that span several weeks,
it gets complicated.

Real life business cases:

1. Schedule 100 emails to be distributed evenly across next 7 days,
skipping weekends:

```ruby
emails = get_emails()
schedule = Stagger.distribute(emails, 7)
```

2. Schedule one item to be sent as soon as possible but on business day
   only:

```ruby
email = get_email() # only one email
schedule = Stagger.distribute([email], 1) # distribute across 1 day
```

3. Schedule 1000 emails to be sent across next 30 days, but only during
   business days:

```ruby
emails = get_emails()
schedule = Stagger.distribute(emails, 30)
```

`schedule` is array of arrays, each item is a pair of original item,
associated with `Time`.

First item is scheduled as soon as possible, while the rest is
distributed evenly across business days.

TODO: plans to add support for holidays / initial delay and working hours in the future.


## Installation

Add this line to your application's Gemfile:

    gem 'stagger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stagger

## Contributing

1. Fork it ( https://github.com/[my-github-username]/stagger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Make sure you run tests with `rspec` command
