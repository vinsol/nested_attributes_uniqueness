require 'nested_attributes_uniqueness'
class TestComponent < ActiveRecord::Base
  has_many :test_tree_nodes, as: :component

  has_many :test_uniqueness_childs, class_name: :TestSubContainer
  has_many :test_scope_childs, class_name: :TestSubContainer
  has_many :test_case_sensitivity_childs, class_name: :TestSubContainer
end
