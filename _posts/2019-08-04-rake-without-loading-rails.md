---
layout: post
title:  "Rake without loading Rails"
date:   2019-08-04 11:00:00 -0700
---
With a simple change, you can avoid loading Rails when running `bin/rake` but still keep `bin/rails` working.

## Goodbye `bin/rake db:migrate`, Hello `bin/rails db:migrate`
Rails 5 introduced a change to [proxy Rake tasks through `bin/rails`](https://guides.rubyonrails.org/5_0_release_notes.html#railties-notable-changes) so that instead of calling `bin/rake` for some commands (e.g. `bin/rake db:migrate`) and `bin/rails` for others (e.g. `bin/rails server`), you can just always use `bin/rails` for everything.

However, Rails will still load your Rails application when you run any Rake task due to the following lines in the generated `Rakefile`:

```ruby
require_relative 'config/application'

Rails.application.load_tasks
```

This isn't too surprising once you realize they haven't moved all of the old Rake tasks over to `bin/rails` entirely, they've just made `bin/rails` act as a proxy that just wraps the Rake tasks.

## Skip loading Rails for non-Rails tasks
But what if you don't want to load Rails for every Rake task? Say you have a Rake task that runs a formatter like [Rubocop](https://github.com/rubocop-hq/rubocop) or [Rufo](https://github.com/ruby-formatter/rufo), why should you have to load the entire Rails framework to run just that one task?

To avoid loading Rails for non-Rails related tasks, you can change those lines in your `Rakefile` to this:

```ruby
def load_rails
  require_relative 'config/application'

  Rails.application.load_tasks
end

load_rails if $0.match?(/rails/)
```

This uses the [`$0` global variable](https://ruby-doc.org/core-2.6.3/doc/globals_rdoc.html) that contains the name of the script being executed (e.g. `bin/rails` or `bin/rake`) and then only loads Rails if it matches `/rails/`.

Now you can run `bin/rake -T` and it will quickly respond with just the non-Rails Rake tasks you've defined yourself.

And you can still run `bin/rails -T` to load Rails and see all of the Rails-related Rake tasks.

## What if you _do_ want to load Rails

But say you have a Rake task that _does_ depend on Rails...

You could make sure that you always call it with `bin/rails` but instead you could explicitly tell Rake to load Rails before running it.

All you need to do is define another task that calls our `load_rails` method:

```ruby
desc "Loads Rails application"
task :load_rails do
  load_rails
end
```

and declare it as a dependency:

```ruby
task :my_task_that_needs_rails => [:load_rails] do
  # ...
end
```

Problem solved!

Now you can call `bin/rake my_task_that_needs_rails` and Rake will load Rails first.

## Should you actually do this?

I don't know! I just thought of this and haven't used it much in practice so there might be a good reason not to do this.

This seems to work on Rails 6.0.0.rc2 but future changes to how `bin/rails` works internally in Rails could cause this to break so beware.

