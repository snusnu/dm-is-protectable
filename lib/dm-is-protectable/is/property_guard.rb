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
          properties, guard = normalize_arguments(properties, guard)
          let(permission, properties, denied_guard(guard))
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
          
          properties, guard = normalize_arguments(properties, guard)
          
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
        
        def normalize_arguments(properties, guard)
          case properties
          when Symbol, String
            [ [ properties ], guard ]
          when TrueClass, FalseClass, Hash
            [ [], properties ]
          else
            [ properties, guard ]
          end
        end
        
        def denied_guard(guard)
          return false if guard.nil? || (guard.is_a?(Hash) && guard.empty?)
          return !guard if guard.is_a?(TrueClass) || guard.is_a?(FalseClass)
          if guard.is_a?(Hash) && guard.size == 1
            if guard.has_key?(:if)
              { :unless => guard[:if] }
            elsif guard.has_key?(:unless)
              { :if => guard[:unless] }
            else
              guard # delegate error handling
            end
          else
            guard # delegate error handling
          end
        end

        def raise_if_invalid_rule!(permission, properties, guard)
          
          unless PERMISSIONS.include?(permission)
            raise InvalidPermission, "permission must be one of #{PERMISSIONS.inspect}"
          end
          
          unless properties.all? { |p| @resource.properties.has_property?(p) }
            msg = "properties must be any/all of #{@resource.properties.map {|p| p.name}.join(',')}"
            raise UnknownProperty, msg
          end
          
          if guard.is_a?(Hash)
            if guard.size == 1
              if GUARD_CONDITIONS.include?(guard.keys.first)
                case guard[guard.keys.first]
                when Symbol, String, TrueClass, FalseClass, NilClass, Proc then
                  # definitely valid if TrueClass, FalseClass, NilClass, Proc
                  # Symbol and String are unsafe to judge at this time of execution
                  # because the methods they reference may well be added after
                  # this check happens (e.g. via include or class_eval or something)
                  return
                else
                  raise InvalidGuard, "guard must be one of true|false|nil|Symbol|String|Proc"
                end
              else
                raise InvalidGuardCondition, "guard condition must be one of #{GUARD_CONDITIONS.inspect}"                
              end
            else
              unless guard.empty?
                msg = "Hash guards must have exactly one key which must be one of #{GUARD_CONDITIONS.inspect}"  
                raise InvalidGuard, msg
              end
            end          
          else
            unless guard.is_a?(TrueClass) || guard.is_a?(FalseClass)
              raise InvalidGuard, "guard must be one of true|false|nil|Hash"
            end
          end
          
        end

      end

      class Rule

        def initialize(rule)
          @rule = rule
        end
        
        def condition_met?(resource)
          return evaluate!(@rule, resource) unless @rule.is_a?(Hash)
          (!@rule.key?(:if)     ||  evaluate!(@rule[:if], resource)) &&
          (!@rule.key?(:unless) || !evaluate!(@rule[:unless], resource))
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
            msg = "'condition' must be true|false|nil|Symbol|String|Proc but was #{condition.class}"
            raise InvalidGuard, msg
          end          
        end

      end

    end
  end
end