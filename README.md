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

```ruby
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
```

If you monkey-patch ActiveRecord::Base as follows, you can actually write the above example in a better form.

**Monkey patch**

```ruby
class ActiveRecord::Base
  def self.as_rusql_table
    t = Rusql::Table.new
    t.name = self.table_name.to_sym

    t   
  end 

  def self.[](ind)
    Rusql::Column.new( self.as_rusql_table, ind )
  end 
end 
```

**Better DSL**

```ruby
class User < ActiveRecord::Base
    extend Rusql

    def self.fetch(id:)
        group_users = table(:group_users)
        
        query = select( 
                    User[:*],
                    group_concat( Group[:name] ).as(:group_names)
                ).
                from( User ).
                left_outer_join( group_users,   group_users[:user_id].equals( User[:id] ) ).
                left_outer_join( Group,         Group[:identifier].equals( group_users[:group_id] ) ).
                where(
                    User[:id].equals(id).
                    and( Group[:created_at].greater_than( 7.days.ago ) )
                ).
                limit(1)
                
        User.find_by_sql( query.to_s ).first
    end
end
```

P.S: The ActiveRecord extensions will be packaged into a gem soon.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sparkymat/rusql. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

