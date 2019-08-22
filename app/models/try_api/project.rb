module TryApi
  class Project < TryApi::Base
    typesafe_accessor :name, String
    typesafe_accessor :menu_items, Array, items_type: TryApi::MenuItem
    typesafe_accessor :protocol, String
    typesafe_accessor :host, String
    typesafe_accessor :port, Integer
    typesafe_accessor :api_prefix, String
    typesafe_accessor :variables, Hash, {}

    def to_json
      super.merge endpoint: endpoint
    end

    def endpoint
      if self.host =~ /^(\S+?):\/\/(.+)$/
        self.protocol = $1
        self.host = $2
      end

      if self.host =~ /^(.+?):(\d+?)$/
        self.host = $1
        self.port = $2.to_i if $2.present?
      end

      URI::Generic.build(scheme: self.protocol, host: self.host, port: self.port).to_s
    end
  end
end