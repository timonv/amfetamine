require 'httparty'

class DummyRestClient
  include HTTParty
  base_uri 'http://test.local'
end
