class FloatValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    !!Float(value) rescue false
  end

  def self.build(param_description, argument, options, block)
    if argument == Float
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}."
  end
end
