require 'json'
require 'net/http'
require_relative 'exceptions'

module Inngest

  class Client
    API_ENDPOINT = "https://inn.gs"
    HEADERS = {
      'Content-Type' => 'application/json',
      'User-Agent' => 'inngest-ruby-sdk/0.0.1',
    }

    def initialize(inngest_key, endpoint = API_ENDPOINT)
      raise InngestException.new "Inngest Key can't be nil" if inngest_key.nil?

      @url = "#{endpoint}/e/#{inngest_key}"
      @http = http_client @url
    end

    def send(event)
      raise InngestException.new "Event can't be nil" if event.nil?
      event = Event.new(**event) if event.is_a? Hash
      raise InngestException.new "Can't construct Event" unless event.is_a? Event

      event.validate
      request = Net::HTTP::Post.new(@url, HEADERS)
      request.body = event.payload.to_json

      @http.request(request)
    end

    private

    def http_client(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.instance_of? URI::HTTPS
      http.read_timeout = 8
      http.open_timeout = 4

      http
    end

  end

  class Event
    attr_accessor :name, :data, :user, :version, :timestamp

    def initialize (name: nil, data: {}, user: {}, version: nil, timestamp: nil)
      @name = name
      @data = data
      @user = user
      @version = version
      @timestamp = timestamp ? timestamp : Time.now.to_i * 1000
    end

    def validate

      unless @name&.strip
        raise InngestException.new "Event name can't be empty"
      end

      unless @data
        raise InngestException.new "Event data can't be empty"
      end

      begin
        @data.to_json
      rescue Exception
        raise InngestException.new "Event data couldn't be serialized to json"
      end
    end

    def payload
      {
        name: @name,
        data: @data,
        user: @user,
        v: @version,
        ts: @timestamp
      }.compact
    end
  end
end
