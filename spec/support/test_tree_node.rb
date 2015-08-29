require 'nested_attributes_uniqueness'
class TestTreeNode < ActiveRecord::Base
  belongs_to :container, polymorphic: true
  belongs_to :component, polymorphic: true
end
