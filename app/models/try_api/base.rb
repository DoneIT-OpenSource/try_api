require 'json'
require 'yaml'
require 'jbuilder'
require 'erubi'
require 'active_support'
require 'active_support/core_ext'

module TryApi
  class Base

    def self.typesafe_accessor(name, type, options={})

      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        if type.is_a?(Array) ? type.any?{|t| value.is_a?(t) } : value.is_a?(type) || value.nil?
          if options[:items_type].try(:<, TryApi::Base)

            items = []
            if value.is_a? Array
              value.each do |item|
                item = load_inclusion(item[:include!]) if item[:include!].present?

                items << options[:items_type].new({ parent: self }.merge(item))
              end
            end

            instance_variable_set("@#{name}", items)
          else
            value = options[:default] if value.nil? && !options[:default].nil?
            instance_variable_set("@#{name}", value)
          end
        else
          raise TryApi::ArgumentError.new "#{ self.class.name }##{ name }=#{ value }(#{ value.class.name })"
        end
      end
    end

    typesafe_accessor :parent, TryApi::Base
    attr_accessor :id

    def to_json(id = 1)
      self.id = id
      result = {}

      self.instance_variables.each do |i|
        value = self.instance_variable_get(i)
        if value.instance_of?(Array)
          result[i.to_s.delete('@')] = value.map do |v|
            id += 1
            v.to_json(id)
          end
        else
          if i == :@parent

          else
            result[i.to_s.delete('@')] = value
          end
        end
      end

      result.with_indifferent_access
    end

    def project
      self.is_a?(TryApi::Project) ? self : self.parent.try(:project)
    end

    def initialize(hash)
      result_hash = {}
      hash.to_h.each do |k, v|
        if k.to_s == 'include!'
          result_hash.merge! load_inclusion(v)
        else
          result_hash[k] = v
        end
      end

      result_hash.to_h.each do |k, v|
        v = self.project.variables[v.gsub('var:', '')] if v.is_a?(String) && v.start_with?('var:')
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    def self.preprocessing(file_body, file_path)
      if file_path =~ /^(.+?)(\.[^.]+?)$/
        case $2
        when '.erb'
          file_body = eval(Erubi::Engine.new(file_body).src)
        when '.jbuilder'
          file_body = Jbuilder.encode &proc { |json| eval(file_body) }
        when '.yml'
          file_body = YAML.load(file_body)
        when '.json'
          file_body = JSON.parse(file_body)
        end
        self.preprocessing(file_body, $1)
      else
        file_body
      end
    end

    def self.load_inclusion(filename)
      base_path = "#{ Rails.root }/config/try_api"
      file_path = Dir.glob("#{base_path}/**/*").find { |i| i =~ /^#{base_path}\/(.+?\/)*?#{filename}(\..+?)*$/ }
      if file_path
        self.preprocessing(File.read(file_path), file_path).with_indifferent_access
      else
        raise ConfigFileNotFound
      end
    end

    def load_inclusion(filename)
      self.class.load_inclusion filename
    end
  end
end
