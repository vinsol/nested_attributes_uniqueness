require 'nested_attributes_uniqueness'
class TestNestedAttributesUniqueness < ActiveRecord::Base
  has_many :test_uniqueness_childs, class_name: :TestChildNestedAttributesUniqueness
  has_many :test_scope_childs, class_name: :TestChildNestedAttributesUniqueness
  has_many :test_case_sensitivity_childs, class_name: :TestChildNestedAttributesUniqueness
  has_many :test_custom_message_childs, class_name: :TestChildNestedAttributesUniqueness

  after_validation do
    # when scope is provided
    validate_unique_nested_attributes(self, test_uniqueness_childs, :name,
      { scope:          :address,
        case_sensitive: false,
        message:        'is already present in this test_nested_attributes_uniqueness'
      }
    )

    # when scope is not provided
    validate_unique_nested_attributes(self, test_scope_childs, :name,
      { case_sensitive: false,
        message:        'is already present in this test_nested_attributes_uniqueness'
      }
    )

    # when case senstivity is true
    validate_unique_nested_attributes(self, test_case_sensitivity_childs, :name,
      { scope:          :address,
        case_sensitive: true
      }
    )

    # when case senstivity is true
    validate_unique_nested_attributes(self, test_custom_message_childs, :name,
      { scope:          :address,
        case_sensitive: true,
        message:        'foo bar custom message'
      }
    )
  end
end
