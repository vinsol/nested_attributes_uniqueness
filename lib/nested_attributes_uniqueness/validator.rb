# This module provides uniqueness validation for nested_attributes.
#
# +USAGE+
#
# class User < ActiveRecord::Base
#   include NestedAttributesUniqueness
#
#   has_many :posts
#
#   validates_uniqueness_in_memory :posts, :name
# end
#
# class Post < ActiveRecord::Base
#   belongs_to :user
# end

# This module also provides uniqueness validation for nested_attributes which are associated with a
# tree polymorphic association.
# It assumes that the tree polymorphic table uses container and component as the name of the
# polymorphic attributes
#
# +USAGE+
#
# class Form < ActiveRecord::Base
#   has_many :form_contents, as: :container
#
#   # Ensures replies have unique content across post
#   validates_uniqueness_in_memory_for_polymorphism :form_contents, :sub_form_group, :sub_forms, :name
# end
#
# class FormContent < ActiveRecord::Base
#   belongs_to :container, polymorphic: true
#   belongs_to :component, polymorphic: true
# end
#
# class SubFormGroup < ActiveRecord::Base
#   has_many :form_contents, as: :component
#   has_many :sub_forms
# end
#
# class SubForm < ActiveRecord::Base
#   belongs_to :sub_form_group
#   has_many form_components, as: :container
# end
module NestedAttributesUniqueness
  module Validator
    extend ::ActiveSupport::Concern

    private
      # Note - can be updated w.r.t. scoped attributes combination
      def validate_unique_nested_attributes(parent, collection, attribute, options = {})
        return true if collection.empty?

        build_default_options(options)
        validate_unique_attribute_in_collection(parent, attribute, collection, options)
      end

      # Note - can be updated w.r.t. scoped attributes combination
      def validate_unique_nested_attributes_for_tree_polymorphism(parent, polymorphic_association_name, type, collection_name, attribute, options = {})
        types_with_collection = find_types_and_all_collections(parent, polymorphic_association_name, type, collection_name)
        return true if types_with_collection.blank?

        build_default_options(options)

        # Maintains unique values for complete collection
        hash = {}

        types_with_collection.each do |component, collection|
          validate_unique_attribute_in_collection(parent, attribute, collection, options, hash)
        end
      end

      def build_default_options(options = {})
        options[:message] ||= "has already been taken"
      end

      def validate_unique_attribute_in_collection(parent, attribute, collection, options, hash = {})
        collection_name = collection.first.class.name.pluralize
        collection.each do |record|
          if (!record.marked_for_destruction? && record.errors.get(attribute).blank?)
            attribute_value = record.send(attribute)
            attribute_value = attribute_value.downcase if options[:case_sensitive] == false
            key = [attribute_value]
            key += Array.wrap(options[:scope]).map { |attribute| record.public_send(attribute) }
            if hash[key] || existing_record_with_attribute?(record, attribute, options)
              record.errors.add(attribute, options[:message])
              add_error_to_base(parent, collection_name)
            else
              (hash[key] = record)
            end
          end
        end
      end

      def existing_record_with_attribute?(record, attribute, options)
        existing_records = record.class.where(:"#{ attribute.to_s }" => record.send(attribute))
        records_exists   = existing_records.present?
        if options[:scope]
          scope_value = record.public_send(options[:scope])
          existing_records = existing_records.where(:"#{ options[:scope] }" => scope_value)
          records_exists = existing_records.present?
        end
        records_exists
      end

      def add_error_to_base(parent, collection_name)
        message = "#{ collection_name } not valid"
        existing_errors = parent.errors
        existing_errors_on_base = (existing_errors.present? ? existing_errors.messages[:base] : nil)
        return if existing_errors_on_base.present? && existing_errors_on_base.include?(message)

        parent.errors.add(:base, message)
      end

      # Returns a hash with component as key and its collection as value.
      # component can be at any level but in hash, it is at root level
      def find_types_and_all_collections(parent, polymorphic_association_name, type, collection_name)
        components = find_desired_components(parent, polymorphic_association_name, type.to_s.camelize.constantize)

        components_with_collection = {}

        components.each do |component|
          components_with_collection[component] = component.send(collection_name)

          components_with_collection[component].each do |collection_element|
            components_with_collection.merge!(find_types_and_all_collections(collection_element, polymorphic_association_name, type, collection_name))
          end
        end
        components_with_collection
      end

      def find_desired_components(parent, polymorphic_association_name, type)
        components = parent.send(:try, polymorphic_association_name).to_a.map(&:component)
        components.map do |component|
          if component.is_a?(type)
            component
          else
            find_desired_components(component, polymorphic_association_name, type)
          end
        end.flatten.compact
      end

    module ClassMethods
      # This method adds an +after_validation+ callback.
      #
      # ==== Parameters
      #
      # * +collection_name+ - The association name that should be used for fetching
      #   collection.
      # * +attribute+ - The attribute name on the association that should be validated.
      # * +options+ - It accepts all options that `UniqunessValidator` accepts.
      #   Default to no options.
      #
      # ==== Example
      #
      #   # Without options
      #   class User < ActiveRecord::Base
      #     include NestedAttributesUniqueness
      #
      #     has_many :posts
      #
      #     validates_uniqueness_in_memory :posts, :name
      #   end
      #
      #   # With options
      #   class User < ActiveRecord::Base
      #     include NestedAttributesUniqueness
      #
      #     has_many :posts
      #
      #     validates_uniqueness_in_memory :posts, :name, { case_sensitive: false }
      #   end
      def validates_uniqueness_in_memory(collection_name, attribute, options = {})
        after_validation do
          validate_unique_nested_attributes self, public_send(collection_name), attribute, options
        end
      end

      # This method adds an +after_validation+ callback.
      #
      # ==== Parameters
      #
      # * +polymorphic_association_name+ - Name of the tree polumorphic association
      #   with container and component as the name of polymorphic attributes
      # * +type+ - The component type in which to look for collection
      # * +collection_name+ - The association name that should be used for fetching
      #   collection.
      # * +attribute+ - The attribute name on the association that should be validated.
      # * +options+ - It accepts all options that `UniqunessValidator` accepts.
      #   Defaults to no options.
      #   Supports scope and case_sensitive options
      def validates_uniqueness_in_memory_for_tree_polymorphism(polymorphic_association_name, type, collection_name, attribute, options = {})
        after_validation do
          validate_unique_nested_attributes_for_tree_polymorphism self, polymorphic_association_name, type, collection_name, attribute, options
        end
      end
    end
  end
end
