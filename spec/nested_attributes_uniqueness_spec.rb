require 'spec_helper'
require_relative '../spec/support/test_nested_attributes_uniqueness.rb'
require_relative '../spec/support/test_child_nested_attributes_uniqueness.rb'

describe NestedAttributesUniqueness do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :test_nested_attributes_uniquenesses, force: true do |t|
        t.string :name
      end

      create_table :test_child_nested_attributes_uniquenesses, force: true do |t|
        t.string :name
        t.string :address
        t.references :test_nested_attributes_uniqueness, index: {name: :ff_bar}
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :test_nested_attributes_uniquenesses
      drop_table :test_child_nested_attributes_uniquenesses
    end
    ActiveRecord::Migration.verbose = true
  end

  describe '#validate_unique_nested_attributes' do
    context 'when scope is provided' do
      before do
        @test = TestNestedAttributesUniqueness.new(name: 'main')
        @test_childs = []
        @test_childs[0] = @test.test_uniqueness_childs.build(name: 'test', address: 'address')
      end

      context 'when parameters are same' do
        before do
          @test_childs[1] = @test.test_uniqueness_childs.build(name: 'test', address: 'address')
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("is already present in this test_nested_attributes_uniqueness")
        end
        it 'has errors associated with its child attributes' do
          @test.valid?
          expect(@test.test_uniqueness_childs.last.errors[:name]).to include("is already present in this test_nested_attributes_uniqueness")
        end
      end

      context 'when parameters are different' do
        before do
          @test_childs[1] = @test.test_uniqueness_childs.build(name: 'test1', address: 'address1')
        end

        it 'validates' do
          expect(@test).to be_valid
        end
        it 'does not have errors' do
          @test.valid?
          expect(@test.errors.count).to eq 0
        end
      end

      context 'when same parameters but different scope' do
        before do
          @test_childs[1] = @test.test_uniqueness_childs.build(name: 'test', address: 'address1')
        end

        it 'validates' do
          expect(@test).to be_valid
        end
        it 'does not have errors' do
          @test.valid?
          expect(@test.errors.count).to eq 0
        end
      end
    end

    context 'when scope is not provided' do
      before do
        @test = TestNestedAttributesUniqueness.new(name: 'main')
        @test_childs = []
        @test_childs[0] = @test.test_scope_childs.build(name: 'test', address: 'address')
      end

      context 'when parameters are same' do
        before do
          @test_childs[1] = @test.test_scope_childs.build(name: 'test', address: 'address')
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("is already present in this test_nested_attributes_uniqueness")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test.test_scope_childs.last.errors[:name]).to include("is already present in this test_nested_attributes_uniqueness")
        end
      end

      context 'when parameters are different' do
        before do
          @test_childs[1] = @test.test_scope_childs.build(name: 'test1', address: 'address1')
        end

        it 'validates' do
          expect(@test).to be_valid
        end
        it 'does not have errors' do
          @test.valid?
          expect(@test.errors.count).to eq 0
        end
      end

      context 'when same parameters but different scope' do
        before do
          @test_childs[1] = @test.test_scope_childs.build(name: 'test', address: 'address1')
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("is already present in this test_nested_attributes_uniqueness")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test.test_scope_childs.last.errors[:name]).to include("is already present in this test_nested_attributes_uniqueness")
        end
      end

      context 'when record already exists with same parameters' do
        before do
          old_test = TestNestedAttributesUniqueness.new(name: 'old')
          old_test.test_scope_childs.build(name: 'test', address: 'address')
          old_test.save
        end

        after do
          TestNestedAttributesUniqueness.destroy_all
          TestChildNestedAttributesUniqueness.destroy_all
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("is already present in this test_nested_attributes_uniqueness")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test.test_scope_childs.last.errors[:name]).to include("is already present in this test_nested_attributes_uniqueness")
        end
      end
    end

    context 'when case senstivity is true' do
      before do
        @test = TestNestedAttributesUniqueness.new(name: 'main')
        @test_childs = []
        @test_childs[0] = @test.test_case_sensitivity_childs.build(name: 'test', address: 'address')
      end

      context 'when parameters are same' do
        before do
          @test_childs[1] = @test.test_case_sensitivity_childs.build(name: 'test', address: 'address')
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("has already been taken")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test.test_case_sensitivity_childs.last.errors[:name]).to include('has already been taken')
        end
      end

      context 'when parameters are different' do
        before do
          @test_childs[1] = @test.test_case_sensitivity_childs.build(name: 'Test', address: 'address')
        end

        it 'validates' do
          expect(@test).to be_valid
        end
        it 'does not have errors' do
          @test.valid?
          expect(@test.errors.count).to eq 0
        end
      end
    end

    context 'when custom message is provided' do
      before do
        @test = TestNestedAttributesUniqueness.new(name: 'main')
        @test_childs = []
        @test_childs[0] = @test.test_custom_message_childs.build(name: 'test', address: 'address')
      end

      context 'when parameters are same' do
        before do
          @test_childs[1] = @test.test_custom_message_childs.build(name: 'test', address: 'address')
        end

        it 'does not validate' do
          expect(@test).to_not be_valid
        end
        it 'has error count 1' do
          @test.valid?
          expect(@test.errors.count).to eq 1
        end
        it 'has errors' do
          @test.valid?
          expect(@test.errors[:base]).to include("foo bar custom message")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test.test_custom_message_childs.last.errors[:name]).to include('foo bar custom message')
        end
      end

      context 'when parameters are different' do
        before do
          @test_childs[1] = @test.test_custom_message_childs.build(name: 'Test', address: 'address')
        end

        it 'validates' do
          expect(@test).to be_valid
        end
        it 'does not have errors' do
          @test.valid?
          expect(@test.errors.count).to eq 0
        end
      end
    end
  end
end
