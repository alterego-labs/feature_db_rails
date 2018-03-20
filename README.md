# FeatureDbRails

When you are working on the big projects with the teammates, could be the situation when you develop
separate big features that might include DB changes, of course. Sometimes you need to switch to the
another feature to help you team or whatever. But on local machine you made some critical changes into
your development DB and without the logic which is in the another branch the application does not
work correctly.

This gem provides the very simple ability to create DB-per-feature. The main goals are:

1. Easy create and revert feature DBs
2. Do not lost data from the original development DB, so you can develop your feature having the whole
data.

This is very dirty implementation of the concept, which I copied from the developing application.

## Requirements

- git
- mysql (unfortunately only mysql is supported now)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'feature_db_rails', '0.2.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install feature_db_rails

Provide a bit of the configuration inside `config/environment.rb`:

```ruby
FeatureDbRails.init(database_original: 'my_dev_db_name')
```

## Usage

Usage is very simple.

For first you need to make change in the `database.yml` file:

```yaml
development:
  <<: *default
  database: <%= FeatureDbRails.target_db_name %>
```

And then you can do a magic:

- When you want to create DB for your feature run `bundle exec rake feature_db_rails:generate`
- If you want to revert DB run `bundle exec rake feature_db_rails:revert`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alterego-labs/feature_db_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

