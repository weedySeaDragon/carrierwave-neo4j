require "rubygems"
require "bundler/setup"
require "rake"
require "rspec"
require "rspec/its"
require "webmock/rspec"

require "active_graph"
require "helpers/database_cleaner"
require "helpers/filesystem_cleaner"
require "helpers/fake_migrations"

require "carrierwave"
require "carrierwave/active_graph"


NEO4J_USERNAME = ENV['NEO4J_DB_USER'] || 'neo4j'
NEO4J_PASSWORD =  ENV['NEO4J_DB_PASSWORD'] || 'password'
SERVER_URL = ENV['NEO4J_URL'] || 'bolt://localhost:7687'

# ----------------------------------------------------------------------------

def file_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "fixtures", *paths))
end

def public_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "public", *paths))
end

def tmp_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'public/uploads/tmp', *paths))
end

CarrierWave.root = public_path
# DatabaseCleaner[:neo4j, connection: {type: :bolt, path: 'bolt://localhost:7006'}].strategy = :transaction

ActiveGraph::Base.driver =
    Neo4j::Driver::GraphDatabase.driver(SERVER_URL, Neo4j::Driver::AuthTokens.basic(NEO4J_USERNAME, NEO4J_PASSWORD), encryption: false)

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.avoid_validation do
      DatabaseCleaner.clean
      FilesystemCleaner.clean
      FakeMigrations.migrate(:up)
    end
  end

  config.after(:each) do
    DatabaseCleaner.avoid_validation { DatabaseCleaner.clean }
  end
end
