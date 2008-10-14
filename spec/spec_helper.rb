require 'rubygems'

gem 'rspec', '>=1.1.3'

require 'spec'
require 'pathname'

require Pathname(__FILE__).dirname.expand_path.parent + 'lib/dm-is-protectable'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  lib = "do_#{name}"

  begin
    gem lib, '>=0.9.5'
    require lib
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')

module Support
  
  def self.unload_class(*classes)
    classes.each do |c|
      Object.send(:remove_const, c) if Object.const_defined?(c)
    end
  end

  def self.fresh_class(name, &block)
    unload_class(name)
    Object.const_set(name, Class.new)
    Object.const_get(name).class_eval(&block)
  end

  def self.fresh_model(name)
    fresh_class(name) do 
            
      include DataMapper::Resource
      property :id,         DataMapper::Types::Serial
      property :firstname,  String
      property :lastname,   String
      property :created_at, DateTime
      property :updated_at, DateTime
      
      def paranoid=(v)
        @paranoid = v
      end
      
      def paranoid?
        !!@paranoid
      end
            
      def funny=(v)
        @funny = v
      end
      
      def funny?
        !!@funny
      end
      
    end
  end

end
