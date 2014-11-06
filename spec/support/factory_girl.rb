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

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record,{:connection => :emop_test}].strategy = :transaction
    DatabaseCleaner[:active_record,{:connection => :emop_test}].clean_with(:truncation)
  end

end
