require File.dirname(__FILE__) + "/../lib/mongo/missing_indexes"
require 'byebug'

if !defined?(Rails)
  class Rails
    class << self
      def logger
        @logger ||= MongoTestLogger.logger
      end
    end
  end
end

module MongoTestLogger
  extend self

  def logger
    @test_logger ||= Logger.new("./test.log")
  end
end

RSpec.configure do |config|
  def wipe_db
    @mongo_db.collection_names.each do |c|
      unless (c =~ /system/)
        @mongo_db[c].drop
      end
    end
  end

  config.before(:all) do
    @test_logger = MongoTestLogger.logger
    @mongo_client = Mongo::MongoClient.new("localhost", 27017)
    @mongo_db = @mongo_client.db("mongo_missing_indexes")
  end

  config.before(:each) do
    wipe_db
  end

  config.expect_with(:rspec) do |c|
    c.syntax = :should
  end
end
