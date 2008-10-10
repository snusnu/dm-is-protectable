module DataMapper
  module Is
    
    # Have a look at the README for more detailed information
    
    module Protectable
      
      PERMISSIONS =      [ :read, :write, :access, :display ]
      GUARD_CONDITIONS = [ :if, :unless ]
      
      class DmIsProtectableException < SecurityError; end
      class InvalidPermission < DmIsProtectableException; end
      class InvalidGuardCondition < DmIsProtectableException; end
      class IllegalPropertyAccess < DmIsProtectableException; end
      class IllegalReadAccess < IllegalPropertyAccess; end
      class IllegalWriteAccess < IllegalPropertyAccess; end
      class IllegalDisplayAccess < IllegalPropertyAccess; end
      
      
      def self.raise_security_error!(permission, attribute)
        case permission
        when :read
          raise IllegalReadAccess, "READ '#{attribute}' is NOT ALLOWED"
        when :write
          raise IllegalWriteAccess, "WRITE '#{attribute}' is NOT ALLOWED" 
        when :display
          raise IllegalDisplayAccess, "DISPLAY '#{attribute}' is NOT ALLOWED"
        when :access
          # do nothing since this will be caught by :read or :write
          # this is here so that no InvalidPermission is raised,
          # but will never happen from inside dm-is-protectable!
          # while at it, return nil to please the coverage gods
          nil
        else
          raise InvalidPermission, "Invalid permission '#{permission}'"
        end
      end
      
      def is_protectable(options = {})
        
        # no need to do things multiple times
        return if respond_to?(:property_guard)
        
        # merge default options
        options = {
          :defaults => true,
          :extended => false
        }.merge(options)
        
        # allow inheriting property guards
        @property_guard = PropertyGuard.new(self)
        class_inheritable_reader :property_guard
        
        extend CoreClassMethods
        extend MoreClassMethods if options[:extended]
        extend DisplayPermissionSupport
        
        include InstanceMethods
        include DisplayPermissionSupport
        
        set_default_permissions! if options[:defaults]
        
      end
      
      module CoreClassMethods
        
        # grant permission on properties
        # ------------------------------------------------------------
        # if properties is nil, empty? or omitted and guard is present
        # * grant guarded permission to all properties 
        # if properties and guard is nil, empty? or omitted
        # * grant unguarded permission to all properties 
        def let(permission, properties = [], guard = {})
          property_guard.let(permission, properties, guard)
        end
        
        # deny permission on properties
        # ------------------------------------------------------------
        # if properties is nil, empty? or omitted and guard is present
        # * grant guarded permission to all properties 
        # if properties and guard is nil, empty? or omitted
        # * grant unguarded permission to all properties 
        def deny(permission, properties = [], guard = {})
          property_guard.deny(permission, properties, guard)
        end
        
        private
        
        # support common patterns
        # overwrite at will (in private class scope)
        def set_default_permissions!
          # Always allow to read the id
          let :read, :id
          # These shouldn't change after the first save.
          let :write, [ :id, :created_at ], :if => :new_record?
          # These can always change.
          let :write, [ :updated_at ]
        end

      end
      
      # Syntactic sugar
      # this can be extended optionally
      module MoreClassMethods
        
        # same as let without guard
        def always_let(permission, properties = [])
          let(permission, properties)
        end
        
        # same as deny without guard
        def always_deny(permission, properties = [])
          deny(permission, properties)
        end
        
        # even more sugar
        alias :never_let :always_deny
        alias :never_deny :always_let
        
      end
    
      module InstanceMethods

        def readable?(property)
          property_guard.readable?(property, self)
        end
      
        def writable?(property)
          property_guard.writable?(property, self)
        end
      
      end
      
      module DisplayPermissionSupport
        
        def displayable?(property)
          property_guard.displayable?(property, self)
        end
        
      end
    
    end
  end
end