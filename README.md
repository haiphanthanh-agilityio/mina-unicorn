# Mina Unicorn

[Mina](https://github.com/nadarei/mina) tasks for handle with
[Unicorn](https://github.com/unicorn/unicorn).

This gem provides several mina tasks:

    mina unicorn:phased_restart  # Restart unicorn (with zero-downtime)
    mina unicorn:restart         # Restart unicorn
    mina unicorn:start           # Start unicorn
    mina unicorn:stop            # Stop unicorn

## Installation

Add this line to your application's Gemfile:

    gem 'mina-unicorn', :require => false

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mina-unicorn
    
Note: by just including this gem, does not mean your development server will be Unicorn, for that, you need explicitly add `gem 'unicorn'` to your Gemfile.

## Usage

Add this to your `config/deploy.rb` file:

    require 'mina/unicorn'

Make sure the following settings are set in your `config/deploy.rb`:

* `deploy_to`   - deployment path

Make sure the following directories exists on your server:

* `shared/tmp/sockets` - directory for socket files.
* `shared/tmp/pids` - directory for pid files.

OR you can set other directories by setting follow variables:

* `unicorn_socket` - unicorn socket file, default is `shared/tmp/sockets/unicorn.sock`
* `unicorn_pid` - unicorn pid file, default `shared/tmp/pids/unicorn.pid`
* `unicorn_state` - unicorn state file, default `shared/tmp/sockets/unicorn.state`
* `unicornctl_socket` - unicornctl socket file, default `shared/tmp/sockets/unicornctl.sock`

Then:

```
$ mina unicorn:start
```

## Example

    require 'mina/unicorn'

    task :setup => :environment do
      # Unicorn needs a place to store its pid file and socket file.
      queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
      queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
      queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
      queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

      ...

    end

    # Add pids and sockets directories to shared paths
    set :shared_paths, ['config/database.yml', 'tmp/pids', 'tmp/sockets']

    task :deploy do
      deploy do
        invoke :'git:clone'
        invoke :'deploy:link_shared_paths'
        ...

        to :launch do
          ...
          invoke :'unicorn:phased_restart'
        end
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
