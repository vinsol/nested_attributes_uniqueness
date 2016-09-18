require 'spec_helper'
require_relative '../spec/support/test_top_container.rb'
require_relative '../spec/support/test_sub_container.rb'
require_relative '../spec/support/test_tree_node.rb'
require_relative '../spec/support/test_component.rb'

describe NestedAttributesUniqueness do
  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :test_top_containers, force: true do |t|
        t.string :name
      end

      create_table :test_sub_containers, force: true do |t|
        t.string :name
        t.string :address
        t.references :test_component
      end

      create_table :test_components, force: true do |t|
        t.string :name
      end

      create_table :test_tree_nodes, force: true do |t|
        t.references :component, polymorphic: true, index: true
        t.references :container, polymorphic: true, index: true
        t.timestamps
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :test_top_containers
      drop_table :test_sub_containers
      drop_table :test_components
      drop_table :test_tree_nodes
    end
    ActiveRecord::Migration.verbose = true
  end

  describe '#validates_uniqueness_in_memory_for_tree_polymorphism' do
    # Cases when scope is provided
    context 'when scope is provided' do
      before do
        @test = TestTopContainer.new(name: 'main')
        @test_nodes = []
        @test_nodes[0] = @test.test_tree_nodes.build
        @test_component1 = TestComponent.new(name: 'main_component1')
        @test_nodes[0].component = @test_component1
        @test_sub_container1 = @test_component1.test_scope_childs.build(name: 'sub_container1', address: 'address1')
        @test_nodes[1] = @test.test_tree_nodes.build
        @test_component2 = TestComponent.new(name: 'main_component2')
        @test_nodes[1].component = @test_component2
        @test_sub_container2 = @test_component2.test_scope_childs.build(name: 'sub_container2', address: 'address2')
      end

      context 'when parameters are same' do
        before do
          @test_sub_container2 = @test_component2.test_scope_childs.build(name: 'sub_container1', address: 'address1')
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
          expect(@test.errors[:base]).to include("is already present in top_container")
        end
        it 'has errors associated with its child attributes' do
          @test.valid?
          expect(@test_component2.test_scope_childs.last.errors[:name]).to include("is already present in top_container")
        end
      end

      context 'when parameters are different' do
        before do
          @test_sub_container2 = @test_component2.test_scope_childs.build(name: 'sub_container3', address: 'address3')
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
          @test_sub_container2 = @test_component2.test_scope_childs.build(name: 'sub_container1', address: 'address3')
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

    # Cases when scope is not provided
    context 'when scope is not provided' do
      before do
        @test = TestTopContainer.new(name: 'main')
        @test_nodes = []
        @test_nodes[0] = @test.test_tree_nodes.build
        @test_component1 = TestComponent.new(name: 'main_component1')
        @test_nodes[0].component = @test_component1
        @test_sub_container1 = @test_component1.test_uniqueness_childs.build(name: 'sub_container1', address: 'address1')
        @test_nodes[1] = @test.test_tree_nodes.build
        @test_component2 = TestComponent.new(name: 'main_component2')
        @test_nodes[1].component = @test_component2
        @test_sub_container2 = @test_component2.test_uniqueness_childs.build(name: 'sub_container2', address: 'address2')
      end

      context 'when parameters are same' do
        before do
          @test_sub_container3 = @test_component2.test_uniqueness_childs.build(name: 'sub_container1', address: 'address1')
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
          expect(@test.errors[:base]).to include("is already present in top_container")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test_component2.test_uniqueness_childs.last.errors[:name]).to include("is already present in top_container")
        end
      end

      context 'when parameters are different' do
        before do
          @test_sub_container3 = @test_component1.test_uniqueness_childs.build(name: 'sub_container3', address: 'address3')
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
          @test_sub_container3 = @test_component2.test_uniqueness_childs.build(name: 'sub_container1', address: 'address3')
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
          expect(@test.errors[:base]).to include("is already present in top_container")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test_component2.test_uniqueness_childs.last.errors[:name]).to include("is already present in top_container")
        end
      end

      context 'when record already exists with same parameters' do
        before do
          old_test = TestTopContainer.new(name: 'old')
          old_test_nodes = []
          old_test_nodes[0] = old_test.test_tree_nodes.build
          old_test_component1 = TestComponent.new(name: 'main_component1')
          old_test_nodes[0].component = old_test_component1
          old_test_component1.test_uniqueness_childs.build(name: 'sub_container1', address: 'address1')
          old_test_nodes[1] = old_test.test_tree_nodes.build
          old_test_component2 = TestComponent.new(name: 'main_component2')
          old_test_nodes[1].component = old_test_component2
          old_test_component2.test_uniqueness_childs.build(name: 'sub_container2', address: 'address2')

          old_test.save
        end

        after do
          TestTopContainer.destroy_all
          TestTreeNode.destroy_all
          TestSubContainer.destroy_all
          TestComponent.destroy_all
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
          expect(@test.errors[:base]).to include("is already present in top_container")
        end
        it 'has errors associated with child attributes' do
          @test.valid?
          expect(@test_component2.test_uniqueness_childs.last.errors[:name]).to include("is already present in top_container")
        end
      end
    end

    # Cases when case sensitivity is true
    context 'when case senstivity is true' do
      before do
        @test = TestTopContainer.new(name: 'main')
        @test_nodes = []
        @test_nodes[0] = @test.test_tree_nodes.build
        @test_component1 = TestComponent.new(name: 'main_component1')
        @test_nodes[0].component = @test_component1
        @test_sub_container1 = @test_component1.test_case_sensitivity_childs.build(name: 'sub_container1', address: 'address1')
        @test_nodes[1] = @test.test_tree_nodes.build
        @test_component2 = TestComponent.new(name: 'main_component2')
        @test_nodes[1].component = @test_component2
        @test_sub_container2 = @test_component2.test_case_sensitivity_childs.build(name: 'sub_container2', address: 'address2')
      end

      context 'when parameters are same' do
        before do
          @test_sub_container3 = @test_component2.test_case_sensitivity_childs.build(name: 'sub_container1', address: 'address1')
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
          expect(@test_component2.test_case_sensitivity_childs.last.errors[:name]).to include('has already been taken')
        end
      end

      context 'when parameters are different' do
        context 'when parameters are different case wise' do
          before do
            @test_sub_container3 = @test_component2.test_case_sensitivity_childs.build(name: 'SUB_CONTAINER1', address: 'address1')
          end

          it 'validates' do
            expect(@test).to be_valid
          end
          it 'does not have errors' do
            @test.valid?
            expect(@test.errors.count).to eq 0
          end
        end
        context 'when parameters are different entirely' do
          before do
            @test_sub_container3 = @test_component2.test_case_sensitivity_childs.build(name: 'sub_container3', address: 'address3')
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
end
