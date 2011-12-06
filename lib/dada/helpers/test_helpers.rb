require 'fakeweb'

module Dada
  module TestHelpers
    # Uses fakeweb to block all connections
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def prevent_external_connections!
        self.rest_client = NeinNeinNein.new
      end

      def stub_responses!(&block)
        prevent_external_connections!
        rest_client.instance_eval(&block)
      end
    end
  end

  # Annoying stub for http responses
  class NeinNeinNein
    def respond_to?(method)
      if [:get,:post,:delete, :put].include?(method)
        true
      else
        super
      end
    end

    def method_missing(method, *args, &block)
      if [:get,:post,:delete,:put].include?(method)
        # TODO: Dump and rewrite
        path = (args.first.is_a?(Hash) ? args.first[:path] : args[0]) || 'default'
        code = args.first.is_a?(Hash) ? args.first[:code] : 200
        paths_with_values = instance_variable_get("@#{method.to_s}") || {}
        
        path.gsub!(/\/$/,'') #remove trailing slash

        if block_given?
          paths_with_values[path]= FakeResponse.new(method, code, block)
          instance_variable_set("@#{method.to_s}", paths_with_values)
        end

        response = paths_with_values ? (paths_with_values[path] || paths_with_values['default']) : nil

        return response if response

        raise Dada::ExternalConnectionsNotAllowed, "Tried to do #{method} with #{args}"
      else
        super
      end
    end

  end

  class FakeResponse
    def initialize(method, code, block)
      @method = method
      @response_code = code
      @inner_body = block.call || {} # For some reason it hangs on nil, the bitch
    end

    def code
      @response_code
    end

    def body
      MultiJson.encode(@inner_body) if @inner_body
    end

    def parsed_response
      if body
        MultiJson.decode(body)
      else
        {}
      end
    end

  end
end

