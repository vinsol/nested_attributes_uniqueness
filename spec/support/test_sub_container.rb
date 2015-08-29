require 'nested_attributes_uniqueness'
class TestSubContainer < ActiveRecord::Base

  belongs_to :test_component
end
