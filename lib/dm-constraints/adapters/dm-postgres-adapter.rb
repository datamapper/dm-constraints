require 'dm-constraints/adapters/dm-do-adapter'

module DataMapper
  module Constraints
    module Adapters

      module PostgresAdapter
        include DataObjectsAdapter
      end

    end
  end
end
