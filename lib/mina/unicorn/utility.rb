module Mina
  module Unicorn
    module Utility
      def upload_template(desc, tpl, destination)
        contents = parse_template(tpl)
        queue %{echo "-----> Put #{desc} file to #{destination}"}
        queue %{echo "#{contents}" > #{destination}}
        queue check_exists(destination)
      end

      def parse_template(file)
        erb("#{file}.erb").gsub('"','\\"').gsub('`','\\\\`').gsub('$','\\\\$')
      end

      def check_response
        'then echo "-----> SUCCESS"; else echo "-----> FAILED"; fi'
      end

      def check_exists(destination)
        %{if [[ -s "#{destination}" ]]; #{check_response}}
      end

      def check_ownership(u, g, destination)
        %{
          file_info=(`ls -l #{destination}`)
          if [[ -s "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
          }
      end

      def check_exec_and_ownership(u, g, destination)
        %{
          file_info=(`ls -l #{destination}`)
          if [[ -s "#{destination}" ]] && [[ -x "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
          }
      end

      def check_symlink(destination)
        %{if [[ -h "#{destination}" ]]; #{check_response}}
      end
    end
  end
end