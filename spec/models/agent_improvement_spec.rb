require 'rails_helper'

RSpec.describe AgentImprovement, type: :model do
  describe 'associations' do
    it { should belong_to(:agent) }
    it { should have_many(:agent_changes).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:improvement_description) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:status) }

    it { should validate_inclusion_of(:priority).in_array(AgentImprovement::PRIORITIES) }
    it { should validate_inclusion_of(:status).in_array(AgentImprovement::STATUSES) }

    context 'priority validation' do
      it 'accepts valid priorities' do
        (1..5).each do |priority|
          improvement = build(:agent_improvement, priority: priority)
          expect(improvement).to be_valid
        end
      end

      it 'rejects priority 0' do
        improvement = build(:agent_improvement, priority: 0)
        expect(improvement).not_to be_valid
      end

      it 'rejects priority 6' do
        improvement = build(:agent_improvement, priority: 6)
        expect(improvement).not_to be_valid
      end
    end

    context 'status validation' do
      it 'accepts valid statuses' do
        AgentImprovement::STATUSES.each do |status|
          improvement = build(:agent_improvement, status: status)
          expect(improvement).to be_valid
        end
      end

      it 'rejects invalid statuses' do
        improvement = build(:agent_improvement, status: 'invalid')
        expect(improvement).not_to be_valid
      end
    end
  end

  describe 'constants' do
    it 'has correct STATUSES' do
      expect(AgentImprovement::STATUSES).to eq(%w[proposed approved implemented rejected])
    end

    it 'has correct PRIORITIES' do
      expect(AgentImprovement::PRIORITIES).to eq([1, 2, 3, 4, 5])
    end
  end

  describe 'scopes' do
    let!(:old_improvement) { create(:agent_improvement, created_at: 2.months.ago) }
    let!(:recent_improvement) { create(:agent_improvement, created_at: 1.day.ago) }
    let!(:proposed) { create(:agent_improvement, :proposed) }
    let!(:approved) { create(:agent_improvement, :approved) }
    let!(:implemented) { create(:agent_improvement, :implemented) }
    let!(:rejected) { create(:agent_improvement, :rejected) }
    let!(:high_priority) { create(:agent_improvement, :high) }
    let!(:critical_priority) { create(:agent_improvement, :critical) }
    let!(:low_priority) { create(:agent_improvement, :low) }

    describe '.recent' do
      it 'orders by created_at descending' do
        improvements = AgentImprovement.where(id: [recent_improvement.id, old_improvement.id]).recent
        expect(improvements.first.id).to eq(recent_improvement.id)
        expect(improvements.last.id).to eq(old_improvement.id)
      end
    end

    describe '.proposed' do
      it 'returns only proposed improvements' do
        expect(AgentImprovement.proposed).to include(proposed)
        expect(AgentImprovement.proposed).not_to include(implemented)
      end
    end

    describe '.approved' do
      it 'returns only approved improvements' do
        expect(AgentImprovement.approved).to include(approved)
        expect(AgentImprovement.approved).not_to include(proposed)
      end
    end

    describe '.implemented' do
      it 'returns only implemented improvements' do
        expect(AgentImprovement.implemented).to include(implemented)
        expect(AgentImprovement.implemented).not_to include(proposed)
      end
    end

    describe '.rejected' do
      it 'returns only rejected improvements' do
        expect(AgentImprovement.rejected).to include(rejected)
        expect(AgentImprovement.rejected).not_to include(proposed)
      end
    end

    describe '.by_priority' do
      it 'returns improvements of specified priority' do
        expect(AgentImprovement.by_priority(4)).to include(high_priority)
        expect(AgentImprovement.by_priority(4)).not_to include(critical_priority)
      end
    end

    describe '.high_priority' do
      it 'returns only high and critical priority improvements' do
        expect(AgentImprovement.high_priority).to include(high_priority, critical_priority)
        expect(AgentImprovement.high_priority).not_to include(low_priority)
      end
    end

    describe '.pending' do
      it 'returns proposed and approved improvements' do
        expect(AgentImprovement.pending).to include(proposed, approved)
        expect(AgentImprovement.pending).not_to include(implemented, rejected)
      end
    end
  end

  describe 'callbacks' do
    describe '#set_implemented_at' do
      it 'sets implemented_at when status changes to implemented' do
        improvement = create(:agent_improvement, :proposed)
        expect(improvement.implemented_at).to be_nil

        improvement.update(status: 'implemented')
        expect(improvement.implemented_at).to be_present
      end

      it 'does not set implemented_at for other status changes' do
        improvement = create(:agent_improvement, :proposed)
        improvement.update(status: 'approved')
        expect(improvement.implemented_at).to be_nil
      end

      it 'does not overwrite existing implemented_at' do
        original_time = 1.week.ago
        improvement = create(:agent_improvement, :implemented, implemented_at: original_time)

        improvement.update(improvement_description: 'Updated description')
        expect(improvement.implemented_at).to be_within(1.second).of(original_time)
      end
    end
  end

  describe '#status_badge_color' do
    it 'returns blue for proposed' do
      improvement = build(:agent_improvement, :proposed)
      expect(improvement.status_badge_color).to eq('blue')
    end

    it 'returns yellow for approved' do
      improvement = build(:agent_improvement, :approved)
      expect(improvement.status_badge_color).to eq('yellow')
    end

    it 'returns green for implemented' do
      improvement = build(:agent_improvement, :implemented)
      expect(improvement.status_badge_color).to eq('green')
    end

    it 'returns red for rejected' do
      improvement = build(:agent_improvement, :rejected)
      expect(improvement.status_badge_color).to eq('red')
    end

    it 'returns gray for unknown status' do
      improvement = build(:agent_improvement)
      allow(improvement).to receive(:status).and_return('unknown')
      expect(improvement.status_badge_color).to eq('gray')
    end
  end

  describe '#priority_badge_color' do
    it 'returns correct colors for each priority' do
      expect(build(:agent_improvement, priority: 1).priority_badge_color).to eq('blue')
      expect(build(:agent_improvement, priority: 2).priority_badge_color).to eq('green')
      expect(build(:agent_improvement, priority: 3).priority_badge_color).to eq('yellow')
      expect(build(:agent_improvement, priority: 4).priority_badge_color).to eq('orange')
      expect(build(:agent_improvement, priority: 5).priority_badge_color).to eq('red')
    end

    it 'returns gray for invalid priority' do
      improvement = build(:agent_improvement)
      allow(improvement).to receive(:priority).and_return(99)
      expect(improvement.priority_badge_color).to eq('gray')
    end
  end

  describe '#priority_label' do
    it 'returns correct labels for each priority' do
      expect(build(:agent_improvement, priority: 1).priority_label).to eq('Very Low')
      expect(build(:agent_improvement, priority: 2).priority_label).to eq('Low')
      expect(build(:agent_improvement, priority: 3).priority_label).to eq('Medium')
      expect(build(:agent_improvement, priority: 4).priority_label).to eq('High')
      expect(build(:agent_improvement, priority: 5).priority_label).to eq('Critical')
    end

    it 'returns Unknown for invalid priority' do
      improvement = build(:agent_improvement)
      allow(improvement).to receive(:priority).and_return(99)
      expect(improvement.priority_label).to eq('Unknown')
    end
  end

  describe '#implemented?' do
    it 'returns true when status is implemented' do
      improvement = build(:agent_improvement, :implemented)
      expect(improvement.implemented?).to be true
    end

    it 'returns false when status is not implemented' do
      improvement = build(:agent_improvement, :proposed)
      expect(improvement.implemented?).to be false
    end
  end

  describe '#pending?' do
    it 'returns true when status is proposed' do
      improvement = build(:agent_improvement, :proposed)
      expect(improvement.pending?).to be true
    end

    it 'returns true when status is approved' do
      improvement = build(:agent_improvement, :approved)
      expect(improvement.pending?).to be true
    end

    it 'returns false when status is implemented' do
      improvement = build(:agent_improvement, :implemented)
      expect(improvement.pending?).to be false
    end

    it 'returns false when status is rejected' do
      improvement = build(:agent_improvement, :rejected)
      expect(improvement.pending?).to be false
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      improvement = build(:agent_improvement)
      expect(improvement).to be_valid
    end

    it 'creates improvements with different descriptions' do
      imp1 = create(:agent_improvement)
      imp2 = create(:agent_improvement)
      expect(imp1.improvement_description).not_to eq(imp2.improvement_description)
    end

    context 'traits' do
      it 'creates proposed improvements' do
        improvement = create(:agent_improvement, :proposed)
        expect(improvement.status).to eq('proposed')
      end

      it 'creates implemented improvements with timestamp' do
        improvement = create(:agent_improvement, :implemented)
        expect(improvement.status).to eq('implemented')
        expect(improvement.implemented_at).to be_present
      end

      it 'creates improvements with changes' do
        improvement = create(:agent_improvement, :with_changes)
        expect(improvement.agent_changes.count).to eq(2)
      end
    end
  end
end
