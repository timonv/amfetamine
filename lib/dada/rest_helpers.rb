require 'active_support/inflector'
require 'json'

module Dada
  module RestHelpers
    class UnknownRESTMethod < Exception; end;

    def rest_path
      self.class.rest_path
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def singular_path
      self.class.base_uri + "#{self.class.rest_path}/#{self.id.to_s}"
    end

    # This method handles the save response
    # TODO: Needs refactoring, now just want to make the test pass =)
    def handle_response(response)
      if response == true
        self.instance_variable_set('@notsaved', false)
        true
      else
        self.instance_variable_set('@errors', response)
        false
      end
    end


    module ClassMethods
      def rest_path
        base_uri + "/#{self.name.downcase.pluralize}"
      end

      def find_path(id)
        base_uri + "#{self.rest_path}/#{id.to_s}"
      end

      def base_uri
        Dada::Config.base_uri
      end

      # wraps rest requests to the corresponding service
      # *emerging*
      def handle_request(method, path, data = nil)
        if(method == :get)
          response = rest_client.get(path)
        elsif(method == :post)
          response = rest_client.post(path, :body => data)
        elsif(method == :put)
          response = rest_client.put(path, :body => data)
        elsif(method == :delete)
          response = rest_client.delete(path)
        else
          raise UnknownRESTMethod, "handle_request only responds to get, put, post and delete"
        end
        parse_response(response)
      end

      # handles response codes, should be refactored later to a more pretty solution without crap.
      def parse_response(response)
        if response.code == 404
          return nil
        elsif response.code.to_s =~ /^20\d{1}$/ && response.body.empty?
          return true
        else
          JSON.parse(response.body)
        end
      end

      def rest_client
        @rest_client || Dada::Config.rest_client
      end

      # Allows setting a different rest client per class
      def rest_client=(value)
        raise ConfigurationInvalidException, 'Invalid value for rest_client' if ![:get,:put,:delete,:post].all? { |m| value.respond_to?(m) }
        @rest_client ||= value
      end
    end
  end
end
