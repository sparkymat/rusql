# Rusql

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rusql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rusql

## Usage

Sample code:

````
class User < ActiveRecord::Base
    extend Rusql

    def self.fetch(id:)
        users = table(:users)
        groups = table(:groups)
        group_users = table(:group_users)
        
        query = select( 
                    users[:*],
                    group_concat( groups[:name] ).as(:group_names)
                ).
                from( users ).
                left_outer_join( group_users,   group_users[:user_id].equals( user[:id] ) ).
                left_outer_join( groups,        groups[:identifier].equals( group_users[:group_id] ) ).
                where(
                    users[:id].equals(id).
                    and( groups[:created_at].greater_than( 7.days.ago ) )
                ).
                limit(1)
                
        User.find_by_sql( query.to_s ).first
    end
end
````

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rusql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

