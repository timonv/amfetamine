require 'active_support/inflector'
require 'json'

module Dada
  module RestHelpers
    class UnknownRESTMethod < Exception; end;

    RESPONSE_STATUSES = { 422 => :errors, 404 => :notfound, 200 => :success, 201 => :created, 500 => :server_error, 406 => :not_acceptable }

    def rest_path
      if self.class._relationship_parents
        relationship = self.send(self.class._relationship_parents.first)
        self.class.rest_path(:relationship => relationship)
      else
        self.class.rest_path
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def singular_path
      if self.class._relationship_parents
        relationship = self.send(self.class._relationship_parents.first)
        self.class.find_path(self.id, :relationship => relationship)
      else
        self.class.find_path(self.id)
      end
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
      def rest_path(params={})
        result = if params[:relationship]
          relationship = params[:relationship]
          "/#{relationship.on.to_s.pluralize}/#{relationship.parent_id}/#{self.name.downcase.pluralize}"
        else
          "/#{self.name.downcase.pluralize}"
        end

        result = base_uri + result unless params[:no_base_uri]
        result = result + resource_suffix unless params[:no_resource_suffix]
        return result
      end

      def find_path(id, params={})
        params_for_rest_path = params.merge({:no_base_uri => true, :no_resource_suffix => true})
        result = "#{self.rest_path(params_for_rest_path)}/#{id.to_s}"

        result = base_uri + result unless params[:no_base_uri]
        result = result + resource_suffix unless params[:no_resource_suffix]
        return result
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

      # Returns a hash with human readable status and parsed body
      def parse_response(response)
        status = RESPONSE_STATUSES.fetch(response.code) { raise "Response not known" }
        raise Dada::RecordNotFound if status == :notfound
        body = response.parsed_response
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
