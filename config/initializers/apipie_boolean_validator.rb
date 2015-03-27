class BooleanValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    return true if value == true || value.to_s =~ /^(true|yes|1)$/
    return true if value == false || value.blank? || value.to_s =~ /^(false|no|0)$/
    return false
  end

  def self.build(param_description, argument, options, block)
    if argument == :boolean
      self.new(param_description, argument)
    end
  end

  def description
    "Must be true, false, 'true', 'false', '1', '0', 'yes', 'no'."
  end
end
