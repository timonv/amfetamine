module Dada
  module TestHelpers
    # Uses fakeweb to block all connections
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Allows for preventing external connections, also in a block
      def prevent_external_connections!
        save_rest_client
        self.rest_client = NeinNeinNein.new

        if block_given?
          yield
          restore_rest_client
        end
      end

      def save_rest_client
        @_old_rest_client = self.rest_client || @_old_rest_client
      end

      def restore_rest_client
        self.rest_client = @_old_rest_client || self.rest_client
      end

      # Prevents external connections and provides a simple dsl
      #
      # Dummy.stub_responses! do |r|
      #   r.get(code: 200, path: '/dummies') { dummy }
      # end  
      def stub_responses!
        prevent_external_connections!
        yield rest_client
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

        # If this is the dsl calling
        if args.first.is_a?(Hash) || args.empty?
          opts = args.first || {}
          path = opts[:path] || 'default'
          code = opts[:code] || 200
          query = opts[:query]
        else # Else this is a request
          path = args[0] || 'default'
          query = args[1][:query]
        end

        paths_with_values = instance_variable_get("@#{method.to_s}") || {}

        path.gsub!(/\/$/,'') #remove trailing slash
        old_path = path
        path += query.to_s.strip

        if block_given?
          paths_with_values[path]= FakeResponse.new(method, code, block)
          instance_variable_set("@#{method.to_s}", paths_with_values)
        end

        response = paths_with_values ? (paths_with_values[path] || paths_with_values[old_path] || paths_with_values['default']) : nil

        return response if response

        raise Dada::ExternalConnectionsNotAllowed, "Tried to do #{method} with #{args}\n Allowed paths: \n #{paths_with_values.keys.join("\n")}"
      else
        super
      end
    end

  end

  class FakeResponse
    def initialize(method, code2, block)
      @method = method
      @response_code = code2 || 200
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

