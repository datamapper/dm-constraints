require 'dm-core'

require 'dm-constraints/delete_constraint'
require 'dm-constraints/relationships'

module DataMapper

  module Constraints

    include DeleteConstraint

    module ClassMethods
      include DeleteConstraint::ClassMethods
    end

    ##
    # Add before hooks to #has to check for proper constraint definitions
    # Add before hooks to #destroy to properly constrain children
    #
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        before_class_method :has, :check_delete_constraint_type

        if instance_methods.any? { |m| m.to_sym == :destroy }
          before :destroy, :check_delete_constraints
        end
      RUBY
    end

    def self.include_constraint_api
      DataMapper::Repository.adapters.values.each do |adapter|
        Adapters.include_constraint_api(ActiveSupport::Inflector.demodulize(adapter.class.name))
      end
    end

    Model.append_inclusions self

  end # module Constraints

  module Adapters

    extend Chainable

    class << self

      def include_constraint_api(const_name)
        require constraint_extensions(const_name)
        if Constraints::Adapters.const_defined?(const_name)
          require 'dm-constraints/migrations'
          DataMapper.extend(Constraints::Migrations::SingletonMethods)
          DataMapper::Model.extend(Constraints::Migrations::Model)
          DataMapper::Model.append_extensions(Constraints::Migrations::Model)
          adapter = const_get(const_name)
          adapter.send(:include, constraint_module(const_name))
        end
      rescue LoadError
        # do nothing
      end

      def constraint_module(const_name)
        Constraints::Adapters.const_get(const_name)
      end

    private

      # @api private
      def constraint_extensions(const_name)
        name = adapter_name(const_name)
        name = 'do' if name == 'dataobjects'
        "dm-constraints/adapters/dm-#{name}-adapter"
      end

    end

    extendable do
      # @api private
      def const_added(const_name)
        include_constraint_api(const_name)
        super
      end
    end

  end # module Adapters

  Constraints.include_constraint_api

end # module DataMapper
