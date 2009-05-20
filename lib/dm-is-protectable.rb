require 'pathname'
require 'dm-core'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-is-protectable' / 'is' / 'version.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-protectable' / 'is' / 'hooks.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-protectable' / 'is' / 'property_guard.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-protectable' / 'is' / 'protectable.rb'

# Include the plugin in DataMapper::Resource
DataMapper::Model.append_extensions DataMapper::Is::Protectable

# Register protection hooks in DataMapper::Property
DataMapper::Property.send(:include, DataMapper::Is::Protectable::Hooks)
