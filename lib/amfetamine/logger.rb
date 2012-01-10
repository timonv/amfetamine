require 'singleton'

module Amfetamine
  class Logger
    include Singleton

    def method_missing(method, args)
      args = "[Amfetamine] #{args.to_s}"
      if defined?(Rails)
        Rails.logger.send(method,args)
      elsif defined?(Merb)
        Merb.logger.send(method,args)
      else
        puts args
      end
    end
  end
end
