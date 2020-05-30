# frozen_string_literal: true

require 'coveralls'
Coveralls.wear_merged!('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end
require 'spec_helper'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include ResponseJSON
  config.filter_gems_from_backtrace('rack', 'railties', 'bootsnap', 'factory_bot_rails')
end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end
