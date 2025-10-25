require 'rails_helper'

RSpec.describe AgentChange, type: :model do
  describe 'associations' do
    it { should belong_to(:agent) }
    it { should belong_to(:agent_invocation).optional }
    it { should belong_to(:agent_issue).optional }
    it { should belong_to(:agent_improvement).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:change_type) }
    it { should validate_presence_of(:change_description) }
    it { should validate_presence_of(:triggered_by) }

    it { should validate_inclusion_of(:change_type).in_array(AgentChange::CHANGE_TYPES) }
    it { should validate_inclusion_of(:triggered_by).in_array(AgentChange::TRIGGERED_BY) }

    context 'change_type validation' do
      it 'accepts valid change types' do
        AgentChange::CHANGE_TYPES.each do |change_type|
          change = build(:agent_change, change_type: change_type)
          expect(change).to be_valid
        end
      end

      it 'rejects invalid change types' do
        change = build(:agent_change, change_type: 'invalid_type')
        expect(change).not_to be_valid
      end
    end

    context 'triggered_by validation' do
      it 'accepts valid triggers' do
        AgentChange::TRIGGERED_BY.each do |trigger|
          change = build(:agent_change, triggered_by: trigger)
          expect(change).to be_valid
        end
      end

      it 'rejects invalid triggers' do
        change = build(:agent_change, triggered_by: 'invalid_trigger')
        expect(change).not_to be_valid
      end
    end
  end

  describe 'constants' do
    it 'has correct CHANGE_TYPES' do
      expected = %w[
        spec_update context_update example_added status_change
        subagent_integration bug_fix capability_added capability_removed
      ]
      expect(AgentChange::CHANGE_TYPES).to eq(expected)
    end

    it 'has correct TRIGGERED_BY' do
      expected = %w[
        invocation_issue user_request improvement refactor initial_creation
      ]
      expect(AgentChange::TRIGGERED_BY).to eq(expected)
    end
  end

  describe 'scopes' do
    let!(:old_change) { create(:agent_change, created_at: 3.months.ago) }
    let!(:recent_change) { create(:agent_change, created_at: 1.day.ago) }
    let!(:spec_update) { create(:agent_change, :spec_update) }
    let!(:bug_fix) { create(:agent_change, :bug_fix) }
    let!(:user_request) { create(:agent_change, :user_request) }
    let!(:improvement) { create(:agent_change, :improvement) }

    describe '.recent' do
      it 'orders by created_at descending' do
        changes = AgentChange.where(id: [recent_change.id, old_change.id]).recent
        expect(changes.first.id).to eq(recent_change.id)
        expect(changes.last.id).to eq(old_change.id)
      end
    end

    describe '.by_type' do
      it 'returns changes of specified type' do
        expect(AgentChange.by_type('spec_update')).to include(spec_update)
        expect(AgentChange.by_type('spec_update')).not_to include(bug_fix)
      end
    end

    describe '.by_trigger' do
      it 'returns changes triggered by specified event' do
        expect(AgentChange.by_trigger('user_request')).to include(user_request)
        expect(AgentChange.by_trigger('user_request')).not_to include(improvement)
      end
    end
  end

  describe '#change_type_label' do
    it 'humanizes change type' do
      change = build(:agent_change, change_type: 'spec_update')
      expect(change.change_type_label).to eq('Spec update')
    end

    it 'handles underscores correctly' do
      change = build(:agent_change, change_type: 'capability_added')
      expect(change.change_type_label).to eq('Capability added')
    end
  end

  describe '#triggered_by_label' do
    it 'humanizes trigger' do
      change = build(:agent_change, triggered_by: 'user_request')
      expect(change.triggered_by_label).to eq('User request')
    end

    it 'handles underscores correctly' do
      change = build(:agent_change, triggered_by: 'invocation_issue')
      expect(change.triggered_by_label).to eq('Invocation issue')
    end
  end

  describe '#change_type_badge_color' do
    it 'returns correct colors for change types' do
      expect(build(:agent_change, change_type: 'spec_update').change_type_badge_color).to eq('blue')
      expect(build(:agent_change, change_type: 'context_update').change_type_badge_color).to eq('blue')
      expect(build(:agent_change, change_type: 'example_added').change_type_badge_color).to eq('green')
      expect(build(:agent_change, change_type: 'status_change').change_type_badge_color).to eq('yellow')
      expect(build(:agent_change, change_type: 'bug_fix').change_type_badge_color).to eq('red')
      expect(build(:agent_change, change_type: 'capability_added').change_type_badge_color).to eq('green')
      expect(build(:agent_change, change_type: 'capability_removed').change_type_badge_color).to eq('orange')
      expect(build(:agent_change, change_type: 'subagent_integration').change_type_badge_color).to eq('purple')
    end

    it 'returns gray for unknown change type' do
      change = build(:agent_change)
      allow(change).to receive(:change_type).and_return('unknown')
      expect(change.change_type_badge_color).to eq('gray')
    end
  end

  describe '#triggered_by_badge_color' do
    it 'returns correct colors for triggers' do
      expect(build(:agent_change, triggered_by: 'invocation_issue').triggered_by_badge_color).to eq('red')
      expect(build(:agent_change, triggered_by: 'user_request').triggered_by_badge_color).to eq('blue')
      expect(build(:agent_change, triggered_by: 'improvement').triggered_by_badge_color).to eq('green')
      expect(build(:agent_change, triggered_by: 'refactor').triggered_by_badge_color).to eq('yellow')
      expect(build(:agent_change, triggered_by: 'initial_creation').triggered_by_badge_color).to eq('purple')
    end

    it 'returns gray for unknown trigger' do
      change = build(:agent_change)
      allow(change).to receive(:triggered_by).and_return('unknown')
      expect(change.triggered_by_badge_color).to eq('gray')
    end
  end

  describe '#has_value_change?' do
    it 'returns true when before_value is present' do
      change = build(:agent_change, before_value: 'old', after_value: nil)
      expect(change.has_value_change?).to be true
    end

    it 'returns true when after_value is present' do
      change = build(:agent_change, before_value: nil, after_value: 'new')
      expect(change.has_value_change?).to be true
    end

    it 'returns true when both values are present' do
      change = build(:agent_change, before_value: 'old', after_value: 'new')
      expect(change.has_value_change?).to be true
    end

    it 'returns false when both values are nil' do
      change = build(:agent_change, before_value: nil, after_value: nil)
      expect(change.has_value_change?).to be false
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      change = build(:agent_change)
      expect(change).to be_valid
    end

    it 'creates changes with different descriptions' do
      change1 = create(:agent_change)
      change2 = create(:agent_change)
      expect(change1.change_description).not_to eq(change2.change_description)
    end

    context 'traits' do
      it 'creates spec_update changes' do
        change = create(:agent_change, :spec_update)
        expect(change.change_type).to eq('spec_update')
      end

      it 'creates status_change with values' do
        change = create(:agent_change, :status_change)
        expect(change.change_type).to eq('status_change')
        expect(change.before_value).to be_present
        expect(change.after_value).to be_present
      end

      it 'creates changes with value changes' do
        change = create(:agent_change, :with_value_changes)
        expect(change.has_value_change?).to be true
      end

      it 'creates fully associated changes' do
        change = create(:agent_change, :fully_associated)
        expect(change.agent_invocation).to be_present
        expect(change.agent_issue).to be_present
        expect(change.agent_improvement).to be_present
      end
    end
  end
end
