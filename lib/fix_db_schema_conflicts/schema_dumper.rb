# lib/fix_db_schema_conflicts/schema_dumper.rb
require 'delegate'

module FixDBSchemaConflicts
  module SchemaDumper
    class << self
      attr_accessor :schema_type
    end

    class ConnectionWithSorting < SimpleDelegator
      def extensions
        __getobj__.extensions.sort
      end

      def columns(table)
        __getobj__.columns(table).sort_by(&:name)
      end

      def indexes(table)
        __getobj__.indexes(table).sort_by(&:name)
      end

      def foreign_keys(table)
        __getobj__.foreign_keys(table).sort_by(&:name)
      end
    end

    def extensions(*args)
      with_sorting do
        super(*args)
      end
    end

    def table(*args)
      with_sorting do
        super(*args)
      end
    end

    def with_sorting
      old, @connection = @connection, ConnectionWithSorting.new(@connection)
      result = yield
      @connection = old
      result
    end

    def filtered_tables
      FixDBSchemaConflicts::SchemaDumper.schema_type == :secondary ? secondary_filtered_tables : primary_filtered_tables
    end

    def primary_filtered_tables
      matchers = %w[schema_migrations ar_internal_metadata]
      matchers << ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']
      @connection.tables.reject { |table| matchers.any? { |matcher| table.start_with?(matcher) } }.sort
    end

    def secondary_filtered_tables
      matcher = ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']
      @connection.tables.select { |table| table.start_with?(matcher) }.sort
    end

    def dump(stream)
      with_sorting do
        header(stream)
        extensions(stream)
        tables(stream)
        trailer(stream)
        stream
      end
    end

    def tables(stream)
      filtered_tables.each do |tbl|
        table(tbl, stream)
      end
      foreign_keys(filtered_tables, stream)
    end

    def foreign_keys(tables, stream)
      all_foreign_keys = tables.flat_map { |table_name| @connection.foreign_keys(table_name) }
      return if all_foreign_keys.empty?

      stream.puts
      all_foreign_keys.sort_by { |fk| [fk.from_table, fk.to_table, fk.name] }.each do |foreign_key|
        statement = "  add_foreign_key #{remove_prefix_and_suffix(foreign_key.from_table).inspect}, #{remove_prefix_and_suffix(foreign_key.to_table).inspect}"
        default_column_name = "#{remove_prefix_and_suffix(foreign_key.to_table).singularize}_id"

        statement << ", column: #{foreign_key.options[:column].inspect}" if foreign_key.options[:column] && foreign_key.options[:column] != default_column_name

        stream.puts statement
      end
      stream.puts
    end
  end
end

ActiveRecord::SchemaDumper.send(:prepend, FixDBSchemaConflicts::SchemaDumper)
