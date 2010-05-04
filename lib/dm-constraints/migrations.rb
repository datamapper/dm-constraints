require 'dm-migrations/auto_migration'

module DataMapper
  module Constraints
    module Migrations

      module SingletonMethods

        def auto_migrate!(repository_name = nil)
          repository_execute(:auto_migrate_down_constraints!, repository_name)
          descendants = super
          repository_execute(:auto_migrate_up_constraints!, repository_name)
          descendants
        end

      private

        def auto_migrate_down!(repository_name = nil)
          repository_execute(:auto_migrate_down_constraints!, repository_name)
          super
        end

        def auto_migrate_up!(repository_name = nil)
          descendants = super
          repository_execute(:auto_migrate_up_constraints!, repository_name)
          descendants
        end

      end

      module Model

      private

        def auto_migrate_down_constraints!(repository_name = self.repository_name)
          return unless storage_exists?(repository_name)
          return if self.respond_to?(:is_remixable?) && self.is_remixable?
          execute_each_relationship(:destroy_relationship_constraint, repository_name)
        end

        def auto_migrate_up_constraints!(repository_name = self.repository_name)
          return if self.respond_to?(:is_remixable?) && self.is_remixable?
          execute_each_relationship(:create_relationship_constraint, repository_name)
        end

        def execute_each_relationship(method, repository_name)
          adapter = DataMapper.repository(repository_name).adapter
          return unless adapter.respond_to?(method)

          relationships(repository_name).each_value do |relationship|
            adapter.send(method, relationship)
          end
        end

      end

    end # module Migrations

  end # module Constraints
end # module DataMapper
