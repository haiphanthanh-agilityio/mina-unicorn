require 'mina/bundler'
require 'mina/rails'
require 'mina/unicorn/utility'

set_default :services_path                  , '/etc/init.d'

set_default :unicorn_config_template        , File.expand_path("../../templates/unicorn.rb", __FILE__)
set_default :unicorn_script_template        , File.expand_path("../../templates/unicorn.sh", __FILE__)
set_default :unicorn_socket                 , -> { "#{deploy_to}/#{shared_path}/sockets/unicorn.sock" }
set_default :unicorn_pid                    , -> { "#{deploy_to}/#{shared_path}/pids/unicorn.pid" }
set_default :unicorn_config                 , -> { "#{deploy_to}/#{shared_path}/config/unicorn.rb" }
set_default :unicorn_logs_path              , -> { "#{deploy_to}/#{shared_path}/logs" }
set_default :unicorn_script                 , -> { "#{services_path}/#{app}-unicorn" }
set_default :unicorn_workers                , 4
set_default :unicorn_bin                    , "#{bundle_prefix} unicorn" # you may prefer this over the line below
set_default :unicorn_user                   , "#{user}"
set_default :unicorn_group                  , "#{group}"

namespace :unicorn do
  include Mina::Unicorn::Utility

  desc "Upload and update (link) all Unicorn config files"
  task :update => [:upload, :link]

  desc "Setup Unicorn folders"
  task :setup do
    queue! %{
      echo "-----> Create Unicorn sockets folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/logs"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/logs"]}
      
      echo "-----> Create Unicorn pids folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/logs"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/logs"]}

      echo "-----> Create Unicorn logs folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/logs"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/logs"]}
    }
  end

  desc "Link unicorn init script"
  task :link => :environment do
    queue %{
      echo "-----> Linking unicorn init script..."
      #{echo_cmd %[sudo cp #{config_path}/unicorn.sh #{unicorn_script}]}
      #{echo_cmd %[sudo chown #{unicorn_user}:#{unicorn_group} #{unicorn_script}]}
      #{echo_cmd %[sudo chmod ugo+x #{unicorn_script}]}
      #{echo_cmd %[sudo update-rc.d #{app}-unicorn defaults]}
    }
    queue check_ownership unicorn_user, unicorn_group, "#{unicorn_script}"
  end

  desc "Parses all Unicorn config files and uploads them to server"
  task :upload => [:'upload:config', :'upload:script']

  namespace :upload do
    desc "Parses Unicorn config file and uploads it to server"
    task :config => :environment do
      queue %{echo "-----> Uploading Unicorn config..."}
      upload_template 'Unicorn config', "#{unicorn_config_template}", "#{config_path}/unicorn.rb"
    end

    desc "Parses Unicorn control script file and uploads it to server"
    task :script => :environment do
      queue %{echo "-----> Uploading Unicorn init script..."}
      upload_template 'Unicorn init script', "#{unicorn_script_template}", "#{config_path}/unicorn.sh"
    end
  end

  desc "Parses all Unicorn config files and shows them in output"
  task :parse => [:'parse:config', :'parse:script']

  namespace :parse do
    desc "Parses Unicorn config file and shows it in output"
    task :config => :environment do
      puts erb("#{unicorn_config_template}")
    end

    desc "Parses Unicorn control script file and shows it in output"
    task :script => :environment do
      puts erb("#{unicorn_script_template}")
    end
  end

  %w(stop start restart).each do |action|
    desc "#{action.capitalize} Unicorn"
    task action.to_sym => :environment do
      queue %{
        echo "-----> #{action.capitalize} Unicorn"
        #{echo_cmd "sudo service #{app}-unicorn #{action}"}
      }
    end
  end

  namespace :daemon do
    desc "Create or remove unicorn daemon"

    desc "Remove unicorn daemon from system"
    task :remove => :'unicorn:stop' do
      queue %{
        echo "-----> Removing Unicorn daemon..."
        #{echo_cmd "sudo update-rc.d -f #{app}-unicorn remove"}
      }
    end
  end
end
