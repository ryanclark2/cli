require "ninefold"
require "securerandom"

class Ninefold::Brutus
  def show
    # print nothing in tests
  end
end

Ninefold::User.instance_eval do
  @netrc_filename = "/tmp/ninefold-cli-test.netrc"
end

class BogusHost
  attr_accessor :name

  def initialize(name="bogus-host.ninefold.com")
    @name = name
  end

  def get(path, options={})
    find_response_for path, options
  end

  def post(path, options={})
    find_response_for path, options
  end

  def find_response_for(path, options)
    request = @requests.detect do |query|
      query.path == path && query.options.to_s == options.to_s
    end

    raise "Expected a request to path: #{path}, params: #{options} " if ! request

    Response.new(request)
  end

  def respond_to(path, options)
    Query.new(path, options).tap do |query|
      @requests ||= []
      @requests << query
    end
  end

  class Response
    def initialize(query)
      @query = query
    end

    def ok?
      @query.status == :ok
    end

    def [](name)
      @query.data[name]
    end
  end

  class Query
    attr_reader :path, :options, :status, :data

    def initialize(path, options)
      @path    = path
      @options = options
    end

    def with(status, data)
      @status = status
      @data   = data
    end
  end
end
