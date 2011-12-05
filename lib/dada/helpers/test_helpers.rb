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
        res = instance_variable_get("@#{method.to_s}")
        if block_given?
          res = FakeResponse.new(method, args.first, block)
          instance_variable_set("@#{method.to_s}", res)
        end

        return res if res

        raise Dada::ExternalConnectionsNotAllowed, "Tried to do #{method} with #{args}"
      else
        super
      end
    end

  end

  class FakeResponse
    def initialize(method, code, block)
      @method = method
      @response_code = code || 200
      @inner_body = block.call || {}
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

