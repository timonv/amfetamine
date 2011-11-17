require 'singleton'

module Dada
  class Logger
    include Singleton

    def method_missing(method, args)
      args = "[Dada] #{args.to_s}"
      if defined?(Rails)
        Rails.logger.public_send(method,args)
      else
        puts args
      end
    end
  end
end
