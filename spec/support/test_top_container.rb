require 'nested_attributes_uniqueness'
class TestTopContainer < ActiveRecord::Base
  has_many :test_tree_nodes, as: :container

  # when scope is provided
  validates_uniqueness_in_memory_for_tree_polymorphism(:test_tree_nodes, :test_component, :test_scope_childs, :name,
    {
      scope:                :address,
      case_sensitive:       false,
      error_message:        'is already present in top_container',
      parent_error_message: 'Multiple TestSubContainers have same name in same address scope.'
    }
  )

  # when scope is not provided
  validates_uniqueness_in_memory_for_tree_polymorphism(:test_tree_nodes, :test_component, :test_uniqueness_childs, :name,
    {
      case_sensitive:       false,
      error_message:        'is already present in top_container'
    }
  )

  # when case senstivity is true
  validates_uniqueness_in_memory_for_tree_polymorphism(:test_tree_nodes, :test_component, :test_case_sensitivity_childs, :name,
    {
      scope:          :address,
      case_sensitive: true
    }
  )
end
