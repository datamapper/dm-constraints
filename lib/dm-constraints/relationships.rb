require 'dm-core'
require 'dm-constraints/delete_constraint'

module DataMapper
  module Associations

    class OneToMany::Relationship

      include DataMapper::Hook
      include Constraints::DeleteConstraint

      OPTIONS << :constraint

      attr_reader :constraint

      # initialize is a private method in Relationship
      # and private methods can not be "advised" (hooked into)
      # in extlib.
      with_changed_method_visibility(:initialize, :private, :public) do
        before :initialize, :add_constraint_option
      end

    end

    class ManyToMany::Relationship

      OPTIONS << :constraint

      private

      # TODO: document
      # @api semipublic
      chainable do
        def one_to_many_options
          super.merge(:constraint => @constraint)
        end
      end
    end

  end
end
