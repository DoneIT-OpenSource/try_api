module TryApi
  class ConfigFileNotFound < StandardError
    def initialize(_message)
      @message = _message
    end

    def message=(_message)
      @message = _message
    end

    def message
      "Configuration file #{ @message } not found."
    end
  end

  class ArgumentError < ArgumentError
    def initialize(_message)
      @message = _message
    end

    def message=(_message)
      @message = _message
    end

    def message
      "Type not allowed here. #{ @message }"
    end
  end
end