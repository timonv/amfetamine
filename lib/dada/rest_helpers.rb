require 'active_support/inflector'
require 'json'

module Dada
  module RestHelpers
    class UnknownRESTMethod < Exception; end;

    def self.included(base)
      base.extend ClassMethods
    end

    def singular_path
      self.class.base_uri + "#{self.class.rest_path}/#{self.id.to_s}"
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
      def handle_request(method, path)
        if(method == :get)
          response = Dada::Config.rest_client.get(path)
        else
          raise UnknownRESTMethod, "handle_request only responds to get, put, post and delete"
        end
        parse_response(response)
      end

      def parse_response(response)
        if response.code == 404
          return nil
        else
          JSON.parse(response.body)
        end
      end

    end
  end
end
