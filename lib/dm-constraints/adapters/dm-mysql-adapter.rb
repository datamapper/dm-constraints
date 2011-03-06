require 'dm-constraints/adapters/dm-do-adapter'

module DataMapper
  module Constraints
    module Adapters

      module MysqlAdapter

        include DataObjectsAdapter

        module SQL
        private

          ##
          # MySQL specific query to drop a foreign key
          #
          # @param storage_name [String]
          #   name of table to constrain
          # @param constraint_name [String]
          #   name of foreign key constraint
          #
          # @return [String]
          #   SQL DDL Statement to destroy a constraint
          #
          # @api private
          def destroy_constraints_statement(storage_name, constraint_name)
            DataMapper::Ext::String.compress_lines(<<-SQL)
              ALTER TABLE #{quote_name(storage_name)}
              DROP FOREIGN KEY #{quote_name(constraint_name)}
            SQL
          end
        end

        include SQL

      end # module MysqlAdapter

    end # module Adapters
  end # module Constraints
end # module DataMapper
