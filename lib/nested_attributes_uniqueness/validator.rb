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

module NestedAttributesUniqueness
  extend ::ActiveSupport::Concern

  private
    # Note - can be updated w.r.t. scoped attributes combination
    def validate_unique_nested_attributes(parent, collection, attribute, options = {})
      return true if collection.empty?
      options[:message] ||= "has already been taken"
      collection_name = collection.first.class.name.pluralize if collection.any?
      hash = {}
      collection.each do |record|
        unless record.errors.get(attribute)
          attribute_value = record.send(attribute)
          attribute_value = attribute_value.downcase if options[:case_sensitive] == false
          if record.marked_for_destruction?
            key = record.object_id
          else
            key = [attribute_value]
            key += Array.wrap(options[:scope]).map { |attribute| record.public_send(attribute) }
          end
          if hash[key]
            record.errors.add(attribute, options[:message])
            parent.errors.add(:base, "#{ collection_name } not valid")
          else
            (hash[key] = record)
          end
        end
      end
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
  end
end
