module Amfetamine
  class InvalidPath < Exception; end; # Only used for paths not having parent ids
  class ConfigurationInvalid < Exception;end; # -red
  class UnknownRESTMethod < Exception; end; # Only used if rest method is not handled by amfetamine
  class RecordNotFound < Exception; end;
  class InvalidCacheData < Exception; end;
  #class MatcherNotImplemented < Exception; end;
  class ExternalConnectionsNotAllowed < Exception; end; # Used for test helpers if connection is not allowed and attempt is made to connect
end
