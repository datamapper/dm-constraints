require 'dm-core'

require 'dm-constraints/migrations'
require 'dm-constraints/delete_constraint'
require 'dm-constraints/relationships'
require 'dm-constraints/adapters/dm-abstract-adapter'

module DataMapper

  extend Constraints::Migrations::SingletonMethods

  module Model
    extend DataMapper::Constraints::Migrations::Model
    append_extensions DataMapper::Constraints::Migrations::Model
  end

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
      DataMapper::Adapters::AbstractAdapter.descendants.each do |adapter_class|
        DataMapper::Adapters.include_constraint_api(DataMapper::Inflector.demodulize(adapter_class.name))
      end
    end

    Model.append_inclusions self

  end # module Constraints

  module Adapters

    class AbstractAdapter
      include DataMapper::Constraints::Adapters::AbstractAdapter
    end

    def self.include_constraint_api(const_name)
      require constraint_extensions(const_name)
      if Constraints::Adapters.const_defined?(const_name)
        adapter = const_get(const_name)
        adapter.send(:include, constraint_module(const_name))
      end
    rescue LoadError
      # Silently ignore the fact that no adapter extensions could be required
      # This means that the adapter in use doesn't support constraints
    end

    def self.constraint_module(const_name)
      Constraints::Adapters.const_get(const_name)
    end

    class << self
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
