# fix-db-schema-conflicts

This is a variation of [fix-db-schema-conflicts](https://github.com/jakeonrails/fix-db-schema-conflicts)
with the main difference being that it supports 2 different databases. 

1. The secondary database should have all tables prepended with something like `second_`. For example `second_users`, `second_services`, etc.
2. The app that is using the gem should store this prepend name (`_second`) in an environmental variable `PRECEDES_SECONDARY_DB_TABLE_NAMES`.

The output schemas will be `db/schema.rb` and `db/second_schema.rb`. In the second_schema.rb, only tables that start with 
`_second` will be present, and none of those will be present in the db/schema.rb file.

If you aren't familiar with the original gem, please read the original README [here](https://github.com/jakeonrails/fix-db-schema-conflicts).

## Installation

Add this line to your application's Gemfile in your development group:

```ruby
gem 'fix-db-schema-conflicts', github: 'wyzyr/fix-db-schema-conflicts', branch: 'master'
```

And then execute:

    $ bundle

## Contributors

 - [@jakeonrails](https://github.com/jakeonrails) - Creator and maintainer
 - [@TCampaigne](https://github.com/TCampaigne)
 - [@Lordnibbler](https://github.com/Lordnibbler)
 - [@timdiggins](https://github.com/timdiggins)
 - [@zoras](https://github.com/zoras)
 - [@jensljungblad](https://github.com/jensljungblad)
 - [@vsubramanian](https://github.com/vsubramanian)
 - [@claytron](https://github.com/claytron)
 - [@amckinnell](https://github.com/amckinnell)
 - [@rosscooperman](https://github.com/rosscooperman)
 - [@cabello](https://github.com/cabello)
 - [@justisb](https://github.com/justisb)
 - [@rogergraves](https://github.com/rogergraves)

## Releases
- 3.2.0
  - Modifications to allow dual database schemas (rogergraves)
- 3.1.0
  - Added support for ruby 3 (cabello)
  - Added support for new Rubocop 0.77+ schema (justisb)
- 3.0.3
  - Added support for new Rubocop 0.53+ schema (rosscooperman)
- 3.0.2
  - Added support for new Rubocop 0.49+ schema (amckinnell)
- 3.0.1
  - Improve formatting to be more consistent (amckinnell)
  - Bump rake dependency to bypass a rake bug in older version (amckinnell)
- 3.0.0
  - Only support Ruby 2.2+ since lower versions haved reached EOL.
- 2.0.1
  - Fix bug that caused failure when project directory has a space in it
- 2.0.0
  - Allow usage of Rubocop >= 0.38.0
  - Remove Rails 5 deprecation warnings for using alias_method_chain
   - This upgrade breaks compatibility with Ruby 1.9x since 1.9x lacks #prepend
- 1.2.2
  - Remove dependency on sed
- 1.2.1
  - Upgrade Rubocop to get major performance boost
  - Add support for sorting of extensions
  - Fix spacing regression introduced by Rubocop upgrade
  - Add test suite and an integration test
