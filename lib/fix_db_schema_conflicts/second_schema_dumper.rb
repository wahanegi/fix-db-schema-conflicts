# lib/fix_db_schema_conflicts/second_schema_dumper.rb
require 'active_record/schema_dumper'

module FixDBSchemaConflicts
  class SecondSchemaDumper < ActiveRecord::SchemaDumper
    def initialize(connection)
      super(connection)
      @table_filter = /^dsight_/
      @foreign_key_filter = @table_filter
    end

    def header(stream)
      define_params = @table_filter ? "table_filter: #{@table_filter.inspect}" : ''
      define_params += ', ' if define_params.present? && @foreign_key_filter.present?
      define_params += @foreign_key_filter ? "foreign_key_filter: #{@foreign_key_filter.inspect}" : ''

      if define_params.present?
        stream.puts "  # This file is auto-generated from the current state of the database. Instead"
        stream.puts "  # of editing this file, please use the migrations feature of Active Record to"
        stream.puts "  # incrementally modify your database, and then regenerate this schema definition."
        stream.puts "  #"
        stream.puts "  # Note that this schema.rb definition is the authoritative source for your"
        stream.puts "  # database schema. If you need to create the application database on another"
        stream.puts "  # system, you should be using db:schema:load, not running all the migrations"
        stream.puts "  # from scratch. The latter is a flawed and unsustainable approach (the more migrations"
        stream.puts "  # you'll amass, the slower it'll run and the greater likelihood for issues)."
        stream.puts "  #"
        stream.puts "  # It's strongly recommended that you check this file into your version control system."
        stream.puts
        stream.puts "  ActiveRecord::Schema.define(#{define_params}) do"
      else
        super(stream)
      end
    end

    def trailer(stream)
      return super(stream) if @table_filter.nil? && @foreign_key_filter.nil?
      stream.puts "  end"
      stream.puts
    end

    def tables(stream)
      @connection.tables.sort.each do |tbl|
        # Only include tables that match the filter
        next unless tbl.match?(@table_filter)
        table(tbl, stream)
      end
    end

    def foreign_keys(table)
      # Only include foreign keys for tables that match the filter
      return [] unless table.match?(@foreign_key_filter)
      super(table)
    end
  end
end
