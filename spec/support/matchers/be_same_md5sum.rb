# REF: https://gist.github.com/mattwynne/736421
RSpec::Matchers.define(:be_same_md5sum) do |expected|
  match do |actual|
    md5_hash(actual) == md5_hash(expected)
  end

  def md5_hash(content)
    Digest::MD5.hexdigest(content)
  end

  failure_message do |actual|
    "expected that #{md5_hash(actual)} would be the same as #{md5_hash(expected)}"
  end
end

# e.g. expect(var_foo).to be_same_md5sum(var_bar)
