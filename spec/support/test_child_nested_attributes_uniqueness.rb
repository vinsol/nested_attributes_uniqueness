require 'nested_attributes_uniqueness'
class TestChildNestedAttributesUniqueness < ActiveRecord::Base

  belongs_to :test_nested_attributes_uniqueness
end
