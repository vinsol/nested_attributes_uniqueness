require 'active_support'
require "nested_attributes_uniqueness/version"
require "nested_attributes_uniqueness/validator"


module NestedAttributesUniqueness
  if defined?(ActiveRecord)
    ActiveRecord::Base.include NestedAttributesUniqueness::Validator
  end
end
