require 'pp'
require 'httparty'

module Typekit
  class API
    include HTTParty

    attr_reader :auth_token

    API_URI = 'https://typekit.com/api/v1/json'

    base_uri API_URI

    def initialize(auth_token)
      @auth_token = auth_token
      self.class.headers('X-Typekit-Token' => auth_token)
    end

    def get_kits
      display_table = []
      response = process_errors(self.class.get('/kits'))

      response['kits'].each do |kit|
        display_kit = get_kit(kit['id'])

        display_table << {
          'name' => display_kit['name'],
          'id' => kit['id'],
          'analytics' => display_kit['analytics'].to_s,
          'domains' => display_kit['domains'].join(',')
        }
      end

      display_table
    end

    def get_kit(id)
      response = process_errors(self.class.get("/kits/#{id}"))

      response.has_key?('kit') ? response['kit'] : []
    end

    def create_kit(name, domains)
      create_body = {name: name, domains: domains}

      process_errors(self.class.post("/kits", body: create_body))
    end

    def publish_kit(id)
      process_errors(self.class.post("/kits/#{id}/publish"))
    end

    def remove_kit(id)
      process_errors(self.class.delete("/kits/#{id}"))
    end

    private

    def process_errors(response)
      if response.has_key?('errors')
        errors = '[red]The server responded with the following error(s):[/] '
        errors << response['errors'].join(',')

        Formatador.display_line(errors)

        exit(1)
      end

      response
    end
  end
end
