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

        # @api private
        def repository_execute(method, repository_name)
          DataMapper::Model.descendants.each do |model|
            model.send(method, repository_name || model.default_repository_name)
          end
        end
      end # module SingletonMethods
    end # module Migrations
  end # module Constraints

  extend Constraints::Migrations::SingletonMethods
end # module DataMapper
