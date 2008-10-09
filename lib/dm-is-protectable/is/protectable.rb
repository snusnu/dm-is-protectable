module DataMapper
  module Is
    
    # -----------------------------------------------------------------------------------
    # Big Thx to Bruce Perens for inspiring this with his ModelSecurity plugin for rails!
    # -----------------------------------------------------------------------------------
    # 
    # DataMapper::Is::Protectable allows you to specify security permissions 
    # on any or all of the properties of any DataMapper::Resource.
    # 
    # Security permissions are specified in the declaration of the resource's class, 
    # The specification includes the names of the properties to which permissions apply, 
    # and an optional permission test that should return true or false 
    # depending on whether the access should be allowed or denied. The permission test
    # can be specified as either a Symbol referencing an instance method on the resource,
    # or as a block to which the current resource instance is yielded.
    # Either way, :if and :unless can be used to clearly express the intent of the test.
    # 
    #  let :read    specifies when the attribute can be read, 
    #  let :write   specifies when it can be written
    #  let :access  does both.
    # 
    # -------------------------------------------------------------------------------------
    #  EXAMPLES (taken from specs)
    # -------------------------------------------------------------------------------------
    #  is :protectable
    # 
    #  let :read, :nick                           # would normally be merged into one
    #  let :read, [ :firstname, :lastname ]       # splitted here only for demonstration
    #  let :read, :pm,                            :if     => :funny?
    #  let :read, [ :phone, :email ],             :unless => :paranoid?
    # 
    #  let :write, :pm
    #  let :write, :nick,                         :if     => :funny?
    #  let :write, [ :phone, :email ],            :unless => :serious?
    # 
    #  let :access, :mood
    #  let :access, :status,                      :if     => :funny?
    #  let :access, [ :birthday, :hobbies ],      :unless => :serious?
    # -------------------------------------------------------------------------------------
    # 
    # No permission test is the same as specifying a test that always returns true.
    # 
    # Tests can easily be added as Symbols that reference instance methods of your Resource:
    # 
    #  let :read, :phone_number :if     => :admin?
    #  let :read, :secret       :unless => :admin?
    # 
    #  def admin?
    #    return current_user.has_role?(:admin)
    #  end
    # 
    # -----------------------------------------------------------------------------
    # TODO: spec this
    # -----------------------------------------------------------------------------
    # 
    # If the permission test is specified as a block, the current 
    # DataMapper::Resource gets yielded to the block.
    # 
    #  let :read, :phone_number :if => lambda do |r|
    #    return r.current_user.has_role?(:admin)
    #  end
    # -----------------------------------------------------------------------------
    # 
    # If no properties are specified for let, that means that the guard 
    # will be hooked before all properties of the resource. 
    # These guards are run first, then any tests for the specific property. 
    # Any test that returns false ends the run, further tests will not be evaluated.
    # 
    #  let :read                  # everything is readable
    #  let :write, :if => admin?  # admins can write everything
    #  let :access                # everything is readable and writable
    # 
    # If *no* security permissions are declared for a property, that property
    # may always be accessed.
    # 
    # The security tests themselves may access any data with impunity. 
    # A thread local variable is used to disable further security testing 
    # while a security test is in progress.
    # 
    # ------------------------------------------------------------------------------
    # 
    # = Accessing Security Test Results
    # 
    # The two instance methods, readable? and writable? are provided
    # to inform the program if a particular property can be accessed. The class
    # method displayable? will return true or false depending upon whether a
    # particular property should should be displayed or not. These can
    # be used to modify a view so that any non-writable data will not be presented
    # in an editable field.
    # 
    # ------------------------------------------------------------------------------
    # 
    # = Exceptions
    # 
    # DataMapper provides two internal methods to access properties: 
    # DataMapper::Property#get and DataMapper::Property#set. 
    # 'before hooks' are registered on these methods that will raise *SecurityError* 
    # when an unpermitted access is attempted.
    # 
    # ------------------------------------------------------------------------------
    # TODO: think about supporting this here (and possibly in a separate gem)
    # ------------------------------------------------------------------------------
    # 
    # = Display Control
    # 
    # A companion mechanism could be used to control views.
    # 
    #  let :display :phone_nr, :if => admin?
    # 
    # let :display could be useful for specifying if a table view should have a
    # column for a particular property. Its tests would have be declared as class
    # methods of the resource, while the tests of let :read, let :write, and
    # let :access are instance methods. This is because the information declared
    # by let :display is accessed before iteration over active records begins.
    # 
    # A DisplayHelper module could overload the methods that are usually used 
    # to edit models so that they will not attempt to read or write what they 
    # aren't permitted, and will render appropriately for the permissions 
    # on any resource property.
    # 
    # Those methods are (in rails)
    # check_box, file_field, hidden_field, password_field, 
    # radio_button, text_area, text_field.
    # --------------------------------------------------------------------------
    
    module Protectable
      
      PERMISSIONS =      [ :read, :write, :access, :display ]
      GUARD_CONDITIONS = [ :if, :unless ]
      
      class DmIsProtectableException < SecurityError; end
      class InvalidPermission < DmIsProtectableException; end
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
          # this is here so that no InvalidPermission is raised
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
        # ------------------------------
        # same as always_let/never_deny if guard is nil or omitted
        # --------------------------------------------------------
        # grant guarded permission to all properties 
        # * if properties is nil or omitted and guard is present
        # grant unguarded permission to all properties 
        # * if properties and guard is nil or omitted
        def let(permission, properties = [], guard = {})
          property_guard.let(permission, properties, guard)
        end
        
        # deny permission on properties
        # -----------------------------
        # same as always_deny/never_let if guard is nil or omitted
        # --------------------------------------------------------
        # grant guarded permission to all properties 
        # * if properties is nil or omitted and guard is present
        # grant unguarded permission to all properties 
        # * if properties and guard is nil or omitted
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