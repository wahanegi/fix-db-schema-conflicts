# lib/fix_db_schema_conflicts/tasks/db.rake

require_relative '../schema_dumper'
require 'shellwords'
require_relative '../autocorrect_configuration'

def dump_schema(filename, schema_type)
  autocorrect_config = FixDBSchemaConflicts::AutocorrectConfiguration.load
  rubocop_yml = File.expand_path("../../../../#{autocorrect_config}", __FILE__)
  ActiveRecord::Base.connection.schema_search_path = 'public'

  FixDBSchemaConflicts::SchemaDumper.schema_type = schema_type
  puts "Dumping database schema #{filename} with fix-db-schema-conflicts gem"
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, File.open(filename, 'w:utf-8'))
  `bundle exec rubocop --auto-correct --config #{rubocop_yml} #{Shellwords.shellescape(filename.to_s)}`
end

namespace :db do
  namespace :schema do
    task :dump_schemas do
      dump_schema(Rails.root.join('db', 'schema.rb'), :primary)
      dump_schema(Rails.root.join('db', "#{ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']}schema.rb"), :secondary)
    end
  end

  # Enhance the existing db:schema:dump task
  Rake::Task['db:schema:dump'].enhance do
    Rake::Task['db:schema:dump_schemas'].invoke
  end

  # Enhance the existing db:migrate task
  Rake::Task['db:migrate'].enhance do
    Rake::Task['db:schema:dump_schemas'].invoke
  end
end
