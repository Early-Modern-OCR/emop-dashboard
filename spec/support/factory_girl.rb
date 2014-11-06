RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
      FactoryGirl.reload
    ensure
      DatabaseCleaner.clean
    end

    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record,{:connection => :emop_test}].strategy = :truncation
    DatabaseCleaner[:active_record,{:connection => :emop_test}].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record,{:connection => :emop_test}].cleaning do
      example.run
    end
  end

end
