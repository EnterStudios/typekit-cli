require 'thor'

module Typekit
  class CLI < Thor
    include Thor::Actions

    def initialize(*args)
      super

      @api = Typekit::API.new(Typekit::Authentication.get_token)
    end

    desc 'logout', 'Remove your cached Adobe Typekit API token'
    def logout
      Typekit::Authentication.clear_token
      Formatador.display_line('[yellow]Successfully logged out[/]')
    end

    desc 'list', 'List available kits'
    def list
      display_table = @api.get_kits

      if display_table.empty?
        Formatador.display_line('[red]No kits found[/]')
      else
        Formatador.display_compact_table(display_table, display_table.first.keys)
      end
    end

    desc 'show', 'Display a specific kit'
    option :id, type: :string, required: true
    def show
      kit = @api.get_kit(options[:id])

      Formatador.display_line("[bold]Name:[/] #{kit['name']}")
      Formatador.display_line("[bold]ID:[/] #{kit['id']}")
      Formatador.display_line("[bold]Analytics:[/] #{kit['analytics']}")
      Formatador.display_line("[bold]Domains:[/] #{kit['domains'].join(',')}")

      Formatador.display_line('[bold]Families:[/]')

      Formatador.indent do
        kit['families'].each do |family|
          Formatador.display_line("[bold]Name:[/] #{family['name']}")
          Formatador.display_line("[bold]ID:[/] #{family['id']}")
          Formatador.display_line("[bold]Slug:[/] #{family['slug']}")
          Formatador.display_line("[bold]CSS Names:[/] #{family['css_names'].join(',')}\n")
        end
      end
    end

    desc 'remove', 'Removes a kit'
    option :id, type: :string, required: true
    def remove
      @api.remove_kit(options[:id])

      Formatador.display_line("[bold][green]Successfully removed kit[/] [bold]#{options[:id]}[/]")
    end

    desc 'create', 'Create a kit'
    option :name, type: :string, required: true
    option :domains, type: :array, required: true
    def create
      response = @api.create_kit(options[:name], options[:domains])
      id = response['kit']['id']

      output = "[bold][green]Successfully created kit[/] "
      output << "[bold]#{options[:name]}[/] "
      output << "[bold][green]with id[/] "
      output << "[bold]#{id}[/]"

      Formatador.display_line(output)
    end

    desc 'publish', 'Publish a kit publicly'
    option :id, type: :string, required: true
    def publish
      @api.publish_kit(options[:id])

      Formatador.display_line("[bold][green]Successfully published kit [/][bold]#{options[:id]}[/]")
    end
  end
end
