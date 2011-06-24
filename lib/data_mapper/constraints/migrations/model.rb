# TODO: figure out some other (less tightly coupled) way to ensure that
# dm-migrations' method implementations are loaded before this file
require "dm-migrations/auto_migration"

module DataMapper
  module Constraints
    module Migrations
      module Model

        def auto_migrate!(repository_name = self.repository_name)
          auto_migrate_down_constraints!(repository_name)
          super
          auto_migrate_up_constraints!(repository_name)
        end

      private

        # @api private
        def auto_migrate_down_constraints!(repository_name = self.repository_name)
          return unless storage_exists?(repository_name)
          # FIXME: this check should not be here
          return if self.respond_to?(:is_remixable?) && self.is_remixable?

          relationships(repository_name).each do |relationship|
            relationship.auto_migrate_down(repository_name)
          end
        end

        # @api private
        def auto_migrate_up_constraints!(repository_name = self.repository_name)
          # FIXME: this check should not be here
          return if self.respond_to?(:is_remixable?) && self.is_remixable?

          relationships(repository_name).each do |relationship|
            relationship.auto_migrate_up(repository_name)
          end
        end
      end # module Model
    end # module Migrations
  end # module Constraints

  Model.append_extensions Constraints::Migrations::Model
end # module DataMapper
