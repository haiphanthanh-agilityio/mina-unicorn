namespace :unicorn do
  namespace :initd do
    desc "Link Unicorn init script"
    task :link => :environment do
      queue %{
        echo "-----> Linking Unicorn init script..."
        #{echo_cmd %[sudo cp #{config_path}/unicorn.sh #{unicorn_script}]}
        #{echo_cmd %[sudo chown #{unicorn_user}:#{unicorn_group} #{unicorn_script}]}
        #{echo_cmd %[sudo chmod ugo+x #{unicorn_script}]}
        #{echo_cmd %[sudo update-rc.d #{app}-unicorn defaults]}
      }
      queue check_ownership unicorn_user, unicorn_group, "#{unicorn_script}"
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

      desc "Remove Unicorn daemon from system"
      task :remove => :'unicorn:stop' do
        queue %{
          echo "-----> Removing Unicorn daemon..."
          #{echo_cmd "sudo update-rc.d -f #{app}-unicorn remove"}
          #{echo_cmd "sudo rm -f #{unicorn_script}"}
        }
      end
    end
  end
end
