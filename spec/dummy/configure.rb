Dada::Config.configure do |config|
  config.memcached_instance = 'localhost:11211'
  config.rest_client = DummyRestClient
end
