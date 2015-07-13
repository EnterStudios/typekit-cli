require 'typekit'
require 'webmock/rspec'

RSpec.configure do |config|
  config.order = :random

  Kernel.srand config.seed

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end
