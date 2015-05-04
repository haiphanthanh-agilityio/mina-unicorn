require 'mina/bundler'
require 'mina/rails'
require 'mina/unicorn/utility'

namespace :unicorn do
  include Mina::Unicorn::Utility

  desc "Set defaults config for Unicorn"
  task :defaults do
    set_default :app_path                       , "#{deploy_to}/#{current_path}"
    set_default :pids_path                      , "#{deploy_to}/#{shared_path}/pids"
    set_default :sockets_path                   , "#{deploy_to}/#{shared_path}/sockets"
    set_default :logs_path                      , "#{deploy_to}/#{shared_path}/log"
    set_default :rvm_path                       , "/usr/local/rvm/scripts/rvm"
    set_default :services_path                  , '/etc/init.d'
    set_default :config_path                    , "#{deploy_to}/#{shared_path}/config"
    set_default :config_templates_path          , "lib/mina/templates"

    set_default :unicorn_socket                 , "#{sockets_path}/unicorn.sock"
    set_default :unicorn_pid                    , "#{pids_path}/unicorn.pid"
    set_default :unicorn_config                 , "#{config_path}/unicorn.rb"
    set_default :unicorn_script                 , "#{services_path!}/unicorn-#{app!}"
    set_default :unicorn_workers                , 4
    set_default :unicorn_bin                    , "#{bundle_prefix} unicorn" # you may prefer this over the line below
    set_default :unicorn_user                   , "#{user}"
    set_default :unicorn_group                  , "#{group}"
  end

  desc "Upload and update (link) all Unicorn config files"
  task :update => [:upload, :link]

  desc "Relocate unicorn script file"
  task :link do
    invoke :sudo
    queue 'echo "-----> Relocate unicorn script file"'
    queue echo_cmd %{sudo cp "#{config_path}/unicorn.sh" "#{unicorn_script!}" && sudo chown #{unicorn_user}:#{unicorn_group} #{unicorn_script} && sudo chmod ugo+x #{unicorn_script} && sudo update-rc.d unicorn-#{app} defaults}
    queue check_ownership unicorn_user, unicorn_group, unicorn_script
  end

  desc "Parses all Unicorn config files and uploads them to server"
  task :upload => [:'upload:config', :'upload:script']

  namespace :upload do
    desc "Parses Unicorn config file and uploads it to server"
    task :config do
      queue %{echo "-----> Uploading Unicorn config..."}
      upload_template 'Unicorn config', 'unicorn.rb', "#{config_path}/unicorn.rb"
    end

    desc "Parses Unicorn control script file and uploads it to server"
    task :script do
      queue %{echo "-----> Uploading Unicorn init script..."}
      upload_template 'Unicorn control script', 'unicorn.sh', "#{config_path}/unicorn.sh"
    end
  end

  desc "Parses all Unicorn config files and shows them in output"
  task :parse => [:'parse:config', :'parse:script']

  namespace :parse do
    desc "Parses Unicorn config file and shows it in output"
    task :config do
      puts erb("#{config_templates_path}/unicorn.rb.erb")
    end

    desc "Parses Unicorn control script file and shows it in output"
    task :script do
      puts erb("#{config_templates_path}/unicorn.sh.erb")
    end
  end

  %w(stop start restart).each do |action|
    desc "#{action.capitalize} Unicorn"
    task action.to_sym => :environment do
      queue %{echo "-----> #{action.capitalize} Unicorn"}
      queue echo_cmd "sudo service unicorn-#{app} #{action}"
    end
  end

  namespace :daemon do
    desc "Create or remove unicorn daemon"

    desc "Remove unicorn daemon from system"
    task :remove => :'unicorn:stop' do
      queue %{echo "-----> Removing Unicorn daemon..."}
      queue echo_cmd "sudo update-rc.d -f unicorn-#{app} remove"
    end
  end
end

invoke :'unicorn:defaults'
