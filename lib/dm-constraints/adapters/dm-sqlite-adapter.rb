module DataMapper
  module Constraints
    module Adapters

      module SqliteAdapter

        def constraint_exists?(*)
          false
        end

        def create_relationship_constraint(*)
          false
        end

        def destroy_relationship_constraint(*)
          false
        end
      end

    end
  end
end
