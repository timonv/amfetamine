module Dada
  class Config
    class << self
      class ConfigurationInvalidException < Exception;end;

      attr_reader :memcached_instance, :rest_client, :base_uri, :resource_suffix

      def configure
        yield(self)
        @base_uri ||= ""
      end

      def memcached_instance=(value, options={})
        raise ConfigurationInvalidException, 'Invalid value for memcached_instance' if !value.is_a?(String)
        @memcached_instance ||= Dalli::Client.new(value, options)
      end

      def rest_client=(value)
        raise ConfigurationInvalidException, 'Invalid value for rest_client' if ![:get,:put,:delete,:post].all? { |m| value.respond_to?(m) }
        @rest_client ||= value
      end

      # Shouldn't be needed as our favourite rest clients are based on httparty, still, added it for opensource reasons
      def base_uri=(value)
        raise ConfigurationInvalidException, "Invalid value for base uri, should be a string" if !value.is_a?(String)
        @base_uri ||= value
      end

      def resource_suffix=(value)
        raise ConfigurationInvalidException, "Invalid value for resource suffix, should be a string" if !value.is_a?(String)
        @resource_suffix ||= value
      end

    end
  end
end
