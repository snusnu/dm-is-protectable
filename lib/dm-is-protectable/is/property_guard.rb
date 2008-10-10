module DataMapper
  module Is
    module Protectable

      class PropertyGuard

        attr_reader :resource, :permissions

        def initialize(resource)
          @resource = resource
          @permissions = PERMISSIONS.inject({}) { |all, p| all[p] = {}; all }
        end

        def let(permission, properties = [], guard = {})
          if permission == :access
            register_guards(:read, properties, guard)
            register_guards(:write, properties, guard)
          else
            register_guards(permission, properties, guard)
          end
        end
        
        def deny(permission, properties = [], guard = {})
          let(permission, properties, guard.empty? ? false : denied_guard(guard))
        end
        
        def readable?(property, resource)
          access_granted?(:read, property, resource)
        end
                
        def writable?(property, resource)
          access_granted?(:write, property, resource)
        end
                        
        def displayable?(property, resource)
          access_granted?(:display, property, resource)
        end
        
        def access_granted?(permission, property, resource)
          Thread.current[:checking_permissions] = true
          # 1) perform checks for :__all__
          (@permissions[permission][:__all__] ||= []).each do |rule| 
            return false unless rule.condition_met?(resource)
          end
          # 2) perform checks for specific properties
          (@permissions[permission][property] ||= []).each do |rule| 
            return false unless rule.condition_met?(resource)
          end
          true
        ensure
          Thread.current[:checking_permissions] = false
        end

        private
        
        def register_guards(permission, properties = [], guard = {})
          properties = (p = properties) && (p.is_a?(Symbol) || p.is_a?(String)) ? [ p ] : p
          raise_if_invalid_rule!(permission, properties, guard)
          if properties && !properties.empty?
            properties.each do |p|
              (@permissions[permission][p.to_sym] ||= []) << Rule.new(guard)
            end
          else
            if properties.nil? || properties.empty?
              (@permissions[permission][:__all__] ||= []) << Rule.new(guard)
            end
          end
        end
        
        def denied_guard(guard)
          if guard.has_key?(:if)
            { :unless => guard[:if] }
          elsif guard.has_key?(:unless)
            { :if => guard[:unless] }
          else
            {}
          end
        end

        def raise_if_invalid_rule!(permission, properties, guard)
          # TODO think about storing a list of common properties and excluding that list from checks
          # unless properties.all? { |p| @resource.properties.has_property?(p) }
          #   msg = "properties must be any/all of #{@resource.properties.map {|p| p.name}.join(',')}"
          #   raise ArgumentError, msg
          # end
          unless PERMISSIONS.include?(permission)
            raise ArgumentError, "permission must be one of #{PERMISSIONS.inspect}"
          end
          return if (guard.is_a?(Hash) && guard.empty?) || guard.is_a?(TrueClass) || guard.is_a?(FalseClass)
          unless guard.is_a?(Hash) && guard.size == 1 && GUARD_CONDITIONS.include?(guard.keys.first)
            raise ArgumentError, "guard condition must be one of #{GUARD_CONDITIONS.inspect}"
          end
        end

      end

      class Rule

        def initialize(rule)
          @rule = rule
        end
        
        # :if is not present or condition evaluates to true
        # :unless is not present or condition evaluates to false
        def condition_met?(resource)
          # ducktyping versus optimization
          # TODO: think about not generating Rule instances instead of these checks
          return @rule if @rule.is_a?(TrueClass) || @rule.is_a?(FalseClass)
          return true if @rule.nil? || (@rule && @rule.empty?)
          ( !@rule.key?(:if)     ||  evaluate!(@rule[:if], resource)) &&
          ( !@rule.key?(:unless) || !evaluate!(@rule[:unless], resource))
        end
        
        private

        def evaluate!(condition, resource)
          case condition
          when TrueClass, FalseClass, NilClass
            return condition
          when Symbol, String :
            return resource.send(condition)
          when Proc :
            return condition.call(resource)
          else
            msg = "'condition' must be true|false|Symbol|String|Proc but was #{condition.class}"
            raise InvalidGuardCondition, msg
          end          
        end

      end

    end
  end
end