require 'active_support/inflector'
require 'json'

module Dada
  module RestHelpers
    class UnknownRESTMethod < Exception; end;

    RESPONSE_STATUSES = { 422 => :errors, 404 => :notfound, 200 => :success, 201 => :created, 500 => :server_error }

    def rest_path
      self.class.rest_path
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def singular_path
      self.class.find_path(self.id)
    end

    # This method handles the save response
    # TODO: Needs refactoring, now just want to make the test pass =)
    # Making assumption here that when response is nil, it should have possitive result. Needs refactor when slept more
    def handle_response(response)
      if response[:status] == :success || response[:status] == :created
        self.instance_variable_set('@notsaved', false)
        true
      elsif response[:errors]
        response[:body].each do |attr, mesg|
          errors.add(attr.to_sym, mesg )
        end
        false
      end
    end


    module ClassMethods
      def rest_path(nested=false)
        if nested
          "/#{self.name.downcase.pluralize}"
        else
          base_uri + "/#{self.name.downcase.pluralize}" + resource_suffix
        end
      end

      def find_path(id)
        base_uri + "#{self.rest_path(true)}/#{id.to_s}" + resource_suffix
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
      # Ofcourse this makes no sense yet. On the other hand, it works fine.
      def parse_response(response)
        status = RESPONSE_STATUSES.fetch(response.code) { raise "Response not known" }
        body = response.body.present? ? JSON.parse(response.body) : nil
        { :status => status, :body => body }
      end

      def rest_client
        @rest_client || Dada::Config.rest_client
      end

      def resource_suffix
        @resource_suffix || Dada::Config.resource_suffix || ""
      end

      # Allows setting a different rest client per class
      def rest_client=(value)
        raise Dada::Config::ConfigurationInvalidException, 'Invalid value for rest_client' if ![:get,:put,:delete,:post].all? { |m| value.respond_to?(m) }
        @rest_client ||= value
      end

      def resource_suffix=(value)
        raise Dada::Config::ConfigurationInvalidException, 'Invalid value for resource suffix' if !value.is_a?(String)
        @resource_suffix = value
      end
    end
  end
end
