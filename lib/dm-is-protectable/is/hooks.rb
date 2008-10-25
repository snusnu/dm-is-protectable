module DataMapper
  module Is
    module Protectable
      
      module Hooks
        
        def self.included(base)
          base.class_eval do
            
            include Extlib::Hook
            
            before :get,         :raise_unless_readable!
            after  :get,         :read_operation_finished!
            
            before :set,         :raise_unless_writable!
            before :default_for, :enter_default_initialization!
            after  :set,         :leave_default_initialization!
            
          end
        end
        
        protected
        
        def raise_unless_readable!(resource)
          return unless resource.class.is_protectable?
          Thread.current[:performing_get] = true
          return if read_permission_check_not_necessary?
          unless resource.readable?(name)
            #1.upto(20) { |i| p "raise_unless_readable![i]: #{caller[i]}<br />" }
            Thread.current[:performing_get] = false
            DataMapper::Is::Protectable.raise_security_error!(:read, name)
          end
        end
        
        def raise_unless_writable!(resource, value)
          return unless resource.class.is_protectable?
          return if write_permission_check_not_necessary?
          unless resource.writable?(name)
            #1.upto(20) { |i| p "raise_unless_writeable![#{i}]: #{caller[i]}<br />" }
            Thread.current[:performing_get] = false if Thread.current[:performing_get]
            DataMapper::Is::Protectable.raise_security_error!(:write, name)
          end
        end
        
        # after :get
        # first parameter is the return value of the advised method
        # the remaining parameters are the same that the advised method accepts
        def read_operation_finished!(retval, resource)
          return unless resource.class.is_protectable?
          Thread.current[:performing_get] = false
        end
        
        def enter_default_initialization!(resource)
          return unless resource.class.is_protectable?
          Thread.current[:initializing_default_values] = true
        end
        
        # after :set
        # first parameter is the return value of the advised method
        # the remaining parameters are the same that the advised method accepts
        def leave_default_initialization!(retval, resource, value)
          return unless resource.class.is_protectable?
          if Thread.current[:initializing_default_values]
            Thread.current[:initializing_default_values] = false
          end
        end
        
        private
        
        def read_permission_check_not_necessary?
          Thread.current[:checking_permissions]
        end
        
        def write_permission_check_not_necessary?
          Thread.current[:checking_permissions] || 
          Thread.current[:performing_get]       || 
          Thread.current[:initializing_default_values]
        end
        
      end
      
    end
  end
end