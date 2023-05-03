# lib/fix_db_schema_conficts/second_schema_dumper.rb

require_relative 'schema_dumper'

module FixDBSchemaConflicts
  class SecondSchemaDumper < ActiveRecord::SchemaDumper
    public_class_method :new

    def filtered_tables
      puts "!!!!! second_schema_dumper.rb#filtered_tables"
      @connection.tables.select { |table| table.start_with?(ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']) }.sort
    end
  end
end
