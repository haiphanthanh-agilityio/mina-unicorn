require 'mina/bundler'
require 'mina/rails'
require 'mina/unicorn/utility'

set_default :unicorn_init                   , 'initd'
set_default :unicorn_service_path           , '/etc/init.d'

set_default :unicorn_config_template        , File.expand_path("../../templates/unicorn.rb", __FILE__)
set_default :unicorn_script_template        , File.expand_path("../../templates/unicorn.sh", __FILE__)
set_default :unicorn_socket                 , -> { "#{deploy_to}/#{shared_path}/sockets/unicorn.sock" }
set_default :unicorn_pid                    , -> { "#{deploy_to}/#{shared_path}/pids/unicorn.pid" }
set_default :unicorn_config                 , -> { "#{deploy_to}/#{shared_path}/config/unicorn.rb" }
set_default :unicorn_logs_path              , -> { "#{deploy_to}/#{shared_path}/log" }
set_default :unicorn_script                 , -> { "#{unicorn_service_path}/#{app}-unicorn" }
set_default :unicorn_workers                , 4
set_default :unicorn_bin                    , "#{bundle_prefix} unicorn" # you may prefer this over the line below
set_default :unicorn_user                   , "#{user}"
set_default :unicorn_group                  , "#{group}"

namespace :unicorn do
  include Mina::Unicorn::Utility 

  desc "Upload and update (link) all Unicorn config files"
  task :update => [:'daemon:remove', :upload, :link]

  desc "Setup Unicorn folders"
  task :setup do
    queue! %{
      echo "-----> Create Unicorn sockets folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/sockets"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/sockets"]}
      
      echo "-----> Create Unicorn pids folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/pids"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/pids"]}

      echo "-----> Create Unicorn logs folder"
      #{echo_cmd %[mkdir -p "#{deploy_to}/#{shared_path}/logs"]}
      #{echo_cmd %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/logs"]}
    }

    invoke :'unicorn:update'
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

  desc "Link Unicorn init script"
  task :link do
    invoke :"unicorn:#{unicorn_init}:link"
  end

  %w(stop start restart).each do |action|
    desc "#{action.capitalize} Unicorn"
    task action.to_sym do
      invoke :"unicorn:#{unicorn_init}:#{action}"
    end
  end

  desc "Remove Unicorn daemon from system"
  task :remove do
    invoke :"unicorn:#{unicorn_init}:remove"
  end
end
