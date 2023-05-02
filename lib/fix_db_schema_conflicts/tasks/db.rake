require_relative '../second_schema_dumper'
require 'shellwords'
require_relative '../autocorrect_configuration'

namespace :db do
  namespace :schema do
    task :dump_schemas do
      puts "Dumping database schemas with fix-db-schema-conflicts gem"

      filename = Rails.root.join('db', 'schema.rb')
      ActiveRecord::Base.connection.schema_search_path = 'public'
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, File.open(filename, 'w:utf-8'))

      autocorrect_config = FixDBSchemaConflicts::AutocorrectConfiguration.load
      rubocop_yml = File.expand_path("../../../../#{autocorrect_config}", __FILE__)
      `bundle exec rubocop --auto-correct --config #{rubocop_yml} #{Shellwords.shellescape(filename.to_s)}`

      filename_schema2 = Rails.root.join('db', "#{ENV['PRECEDES_SECONDARY_DB_TABLE_NAMES']}schema.rb")
      ActiveRecord::Base.connection.schema_search_path = 'public'
      FixDBSchemaConflicts::SecondSchemaDumper.dump(ActiveRecord::Base.connection, File.open(filename_schema2, 'w:utf-8'))

      `bundle exec rubocop --auto-correct --config #{rubocop_yml} #{Shellwords.shellescape(filename_schema2.to_s)}`
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
