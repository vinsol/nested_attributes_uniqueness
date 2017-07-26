NestedAttributesUniqueness
-------

This gem provides two class methods `validates_uniqueness_in_memory` and `validates_uniqueness_in_memory_for_tree_polymorphism` which ensures that the nested attribute uniqueness validation is not only checked against DB records but also against the non-persisted objects in memory.

Installation
-------

Add this line to your application's Gemfile:

```shell
gem 'nested_attributes_uniqueness', '~> 1.0.1'
```

And then install dependencies using bundler:

```shell
$ bundle
```

Or install it as system gem:

```shell
$ gem install nested_attributes_uniqueness
```

Usage
-------

For _ActiveRecord:_

```ruby
  class User < ActiveRecord::Base
    include NestedAttributesUniqueness

    has_many :posts

    validates_uniqueness_in_memory :posts, :name, { scope: user_id, case_sensitive: false }
  end
```


Testing
-------

```shell
$ bundle
$ bundle exec rspec spec
```

Contributing
-------

```
1. Fork it ( https://github.com/vinsol/nested_attributes_uniqueness/fork ).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Add test cases and verify all tests are green.
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create new Pull Request.
```
