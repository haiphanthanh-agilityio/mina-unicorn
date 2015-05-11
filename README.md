# Mina Unicorn
Mina tasks for Unicorn, that will create and manage unicorn process via init.d

[Mina](https://github.com/nadarei/mina) tasks for handle with
[Unicorn](https://github.com/unicorn/unicorn).

This gem provides several mina tasks:

    mina unicorn:setup           # Create necessary folders, configs and upload to server
    mina unicorn:restart         # Restart unicorn
    mina unicorn:start           # Start unicorn
    mina unicorn:stop            # Stop unicorn
    mina unicorn:remove          # Remove all configs and unicorn service from system

## Installation

Add this line to your application's Gemfile:

    gem 'mina-unicorn', git: 'git@github.com:haiphan-asnet/mina-unicorn.git', :require => false

And then execute:

    $ bundle install    

Note: by just including this gem, does not mean your development server will be Unicorn, for that, you need explicitly add `gem 'unicorn'` to your Gemfile.

## Usage

Add this to your `config/deploy.rb` file:

    require 'mina/unicorn'

Make sure the following settings are set in your `config/deploy.rb`:

* `app`         - application name
* `deploy_to`   - deployment path

## Settings
Any and all of these settings can be overriden in your `deploy.rb`.

* `unicorn_config_template`     - config template file that unicorn runs with (that is a local *.rb.erb template file)
* `unicorn_script_template`     - sh script template file to manage unicorn init.d process (that is a local *.sh.erb template file)
* `unicorn_socket`              - path to unicorn socket, default is `-> { #{deploy_to}/#{shared_path}/sockets/unicorn.sock" }`
* `unicorn_pid`                 - path to unicorn pid, default is `-> { "#{deploy_to}/#{shared_path}/pids/unicorn.pid" }`
* `unicorn_config`              - path to unicorn pid, default is `-> { "#{deploy_to}/#{shared_path}/config/unicorn.rb" }`
* `unicorn_logs_path`           - path to unicorn logs folder, default is `-> { "#{deploy_to}/#{shared_path}/log" }`
* `unicorn_workers`             - number of unicorn workers, default is `4`
* `unicorn_bin`                 - command to start unicorn, default is `#{bundle_prefix} unicorn"`

## Example

    require 'mina/unicorn'

    task :setup => :environment do
      ...

      # Unicorn setup.
      invoke :'unicorn:setup'

      ...
    end

    task :deploy do
      deploy do
        invoke :'git:clone'
        invoke :'deploy:link_shared_paths'
        ...

        to :launch do
          ...
          invoke :'unicorn:restart'
        end
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
