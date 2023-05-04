# lib/fix_db_schema_conflicts/tasks/db.rake

require_relative '../schema_dumper'
require 'shellwords'
require_relative '../autocorrect_configuration'

namespace :db do
  namespace :schema do
    task :dump_primary_schema do
      autocorrect_config = FixDBSchemaConflicts::AutocorrectConfiguration.load
      rubocop_yml = File.expand_path("../../../../#{autocorrect_config}", __FILE__)
      ActiveRecord::Base.connection.schema_search_path = 'public'

      filename = Rails.root.join('db', 'schema.rb')
      puts "Dumping database schema #{filename} with fix-db-schema-conflicts gem"
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, File.open(filename, 'w:utf-8'))
      `bundle exec rubocop --auto-correct --config #{rubocop_yml} #{Shellwords.shellescape(filename.to_s)}`
    end

    task :dump_secondary_schema do
      next if ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES'].blank?

      autocorrect_config = FixDBSchemaConflicts::AutocorrectConfiguration.load
      rubocop_yml = File.expand_path("../../../../#{autocorrect_config}", __FILE__)
      ActiveRecord::Base.connection.schema_search_path = 'public'

      filename = Rails.root.join('db', "#{ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']}schema.rb")
      puts "Dumping database schema #{filename} with fix-db-schema-conflicts gem"
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, File.open(filename, 'w:utf-8'))
      `bundle exec rubocop --auto-correct --config #{rubocop_yml} #{Shellwords.shellescape(filename.to_s)}`
    end

    task :dump_schemas do
      Rake::Task['db:schema:dump_primary_schema'].invoke
      Rake::Task['db:schema:dump_secondary_schema'].invoke
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
