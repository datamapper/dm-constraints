module DataMapper
  module Constraints
    module Adapters

      module DataObjectsAdapter
        ##
        # Determine if a constraint exists for a table
        #
        # @param storage_name [Symbol]
        #   name of table to check constraint on
        # @param constraint_name [~String]
        #   name of constraint to check for
        #
        # @return [Boolean]
        #
        # @api private
        def constraint_exists?(storage_name, constraint_name)
          statement = DataMapper::Ext::String.compress_lines(<<-SQL)
            SELECT COUNT(*)
            FROM #{quote_name('information_schema')}.#{quote_name('table_constraints')}
            WHERE #{quote_name('constraint_type')} = 'FOREIGN KEY'
            AND #{quote_name('table_schema')} = ?
            AND #{quote_name('table_name')} = ?
            AND #{quote_name('constraint_name')} = ?
          SQL

          select(statement, schema_name, storage_name, constraint_name).first > 0
        end

        ##
        # Create the constraint for a relationship
        #
        # @param relationship [Relationship]
        #   the relationship to create the constraint for
        #
        # @return [true, false]
        #   true if creating the constraints was successful
        #
        # @api semipublic
        def create_relationship_constraint(relationship)
          return false unless valid_relationship_for_constraint?(relationship)

          source_model = relationship.source_model
          source_table = source_model.storage_name(name)
          source_key   = relationship.source_key

          constraint_name = constraint_name(source_table, relationship.name)
          return false if constraint_exists?(source_table, constraint_name)

          constraint_type = case relationship.inverse.constraint
            when :protect            then 'NO ACTION'
            when :destroy, :destroy! then 'CASCADE'
            when :set_nil            then 'SET NULL'
          end

          return false if constraint_type.nil?

          storage_name           = relationship.source_model.storage_name(name)
          reference_storage_name = relationship.target_model.storage_name(name)

          foreign_keys   = relationship.source_key.map { |p| property_to_column_name(p, false) }
          reference_keys = relationship.target_key.map { |p| property_to_column_name(p, false) }

          execute(create_constraints_statement(storage_name, constraint_name, constraint_type, foreign_keys, reference_storage_name, reference_keys))
        end

        ##
        # Remove the constraint for a relationship
        #
        # @param relationship [Relationship]
        #   the relationship to remove the constraint for
        #
        # @return [true, false]
        #   true if destroying the constraint was successful
        #
        # @api semipublic
        def destroy_relationship_constraint(relationship)
          return false unless valid_relationship_for_constraint?(relationship)

          source_model = relationship.source_model
          source_table = source_model.storage_name(name)

          constraint_name = constraint_name(source_table, relationship.name)
          return false unless constraint_exists?(source_table, constraint_name)

          execute(destroy_constraints_statement(source_table, constraint_name))
        end

        private

        ##
        # Check to see if the relationship's constraints can be used
        #
        # Only one-to-one, one-to-many, and many-to-many relationships
        # can be used for constraints.  They must also be in the same
        # repository as the adapter is connected to.
        #
        # @param relationship [Relationship]
        #   the relationship to check
        #
        # @return [true, false]
        #   true if a constraint can be established for relationship
        #
        # @api private
        def valid_relationship_for_constraint?(relationship)
          return false unless relationship.source_repository_name == name || relationship.source_repository_name.nil?
          return false unless relationship.target_repository_name == name || relationship.target_repository_name.nil?
          return false unless relationship.kind_of?(Associations::ManyToOne::Relationship)
          true
        end

        module SQL
          private

          ##
          # Generates the SQL statement to create a constraint
          #
          # @param constraint_name [String]
          #   name of the foreign key constraint
          # @param constraint_type [String]
          #   type of foreign key constraint to add to the table
          # @param storage_name [String]
          #   name of table to constrain
          # @param foreign_keys [Array[String]]
          #   columns in the table that refer to foreign table
          # @param reference_storage_name [String]
          #   table the foreign key refers to
          # @param reference_storage_name [Array[String]]
          #   columns the foreign table that are referred to
          #
          # @return [String]
          #   SQL DDL Statement to create a constraint
          #
          # @api private
          def create_constraints_statement(storage_name, constraint_name, constraint_type, foreign_keys, reference_storage_name, reference_keys)
            DataMapper::Ext::String.compress_lines(<<-SQL)
              ALTER TABLE #{quote_name(storage_name)}
              ADD CONSTRAINT #{quote_name(constraint_name)}
              FOREIGN KEY (#{foreign_keys.join(', ')})
              REFERENCES #{quote_name(reference_storage_name)} (#{reference_keys.join(', ')})
              ON DELETE #{constraint_type}
              ON UPDATE #{constraint_type}
            SQL
          end

          ##
          # Generates the SQL statement to destroy a constraint
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
              DROP CONSTRAINT #{quote_name(constraint_name)}
            SQL
          end

          ##
          # generates a unique constraint name given a table and a relationships
          #
          # @param storage_name [String]
          #   name of table to constrain
          # @param relationships_name [String]
          #   name of the relationship to constrain
          #
          # @return [String]
          #   name of the constraint
          #
          # @api private
          def constraint_name(storage_name, relationship_name)
            identifier = "#{storage_name}_#{relationship_name}"[0, self.class::IDENTIFIER_MAX_LENGTH - 3]
            "#{identifier}_fk"
          end
        end

        include SQL

      end # module DataObjectsAdapter

    end # module Adapters
  end # module Constraints
end # module DataMapper
