module Typekit
  class Authentication
    TOKEN_FILE = '.typekit'

    class << self
      def authenticated?
        get_token.to_s.length > 0
      end

      def get_token
        File.exist?(token_path) ? File.open(token_path, 'r').gets : nil
      end

      def token_path
        File.join(Dir.home, TOKEN_FILE)
      end

      def clear_token
        File.unlink(token_path) if File.exist?(token_path)
      end

      def prompt_for_token
        Formatador.display('[yellow]Please enter your Adobe Typekit API token: [/]')
        token = STDIN.gets.chomp

        File.open(token_path, 'w') do |file|
          file.write(token)
        end
      end
    end
  end
end
