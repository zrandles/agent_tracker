require 'rails_helper'

RSpec.describe Agent, type: :model do
  describe 'associations' do
    it { should have_many(:agent_invocations).dependent(:destroy) }
    it { should have_many(:agent_issues).dependent(:destroy) }
    it { should have_many(:agent_improvements).dependent(:destroy) }
    it { should have_many(:agent_changes).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:agent) }

    it { should validate_presence_of(:agent_number) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:tier) }
    it { should validate_presence_of(:status) }

    it { should validate_uniqueness_of(:agent_number) }
    it { should validate_numericality_of(:agent_number).only_integer.is_greater_than(0) }

    it { should validate_inclusion_of(:category).in_array(Agent::CATEGORIES) }
    it { should validate_inclusion_of(:tier).in_array(Agent::TIERS) }
    it { should validate_inclusion_of(:status).in_array(Agent::STATUSES) }

    context 'agent_number validation' do
      it 'allows positive integers' do
        agent = build(:agent, agent_number: 42)
        expect(agent).to be_valid
      end

      it 'rejects zero' do
        agent = build(:agent, agent_number: 0)
        expect(agent).not_to be_valid
      end

      it 'rejects negative numbers' do
        agent = build(:agent, agent_number: -1)
        expect(agent).not_to be_valid
      end

      it 'rejects duplicate agent numbers' do
        create(:agent, agent_number: 1)
        duplicate = build(:agent, agent_number: 1)
        expect(duplicate).not_to be_valid
      end
    end

    context 'category validation' do
      it 'accepts valid categories' do
        Agent::CATEGORIES.each do |category|
          agent = build(:agent, category: category)
          expect(agent).to be_valid
        end
      end

      it 'rejects invalid categories' do
        agent = build(:agent, category: 'invalid_category')
        expect(agent).not_to be_valid
      end
    end

    context 'tier validation' do
      it 'accepts valid tiers' do
        (1..5).each do |tier|
          agent = build(:agent, tier: tier)
          expect(agent).to be_valid
        end
      end

      it 'rejects tier 0' do
        agent = build(:agent, tier: 0)
        expect(agent).not_to be_valid
      end

      it 'rejects tier 6' do
        agent = build(:agent, tier: 6)
        expect(agent).not_to be_valid
      end
    end

    context 'status validation' do
      it 'accepts valid statuses' do
        Agent::STATUSES.each do |status|
          agent = build(:agent, status: status)
          expect(agent).to be_valid
        end
      end

      it 'rejects invalid statuses' do
        agent = build(:agent, status: 'invalid_status')
        expect(agent).not_to be_valid
      end
    end
  end

  describe 'constants' do
    it 'has correct STATUSES' do
      expect(Agent::STATUSES).to eq(%w[active inactive deprecated archived])
    end

    it 'has correct CATEGORIES' do
      expected = %w[
        research planning writing coding debugging deployment
        database testing monitoring analysis optimization security
        infrastructure documentation design marketing finance operations
      ]
      expect(Agent::CATEGORIES).to eq(expected)
    end

    it 'has correct TIERS' do
      expect(Agent::TIERS).to eq([1, 2, 3, 4, 5])
    end
  end

  describe 'scopes' do
    let!(:active_agent) { create(:agent, :active) }
    let!(:inactive_agent) { create(:agent, :inactive) }
    let!(:research_agent) { create(:agent, category: 'research') }
    let!(:coding_agent) { create(:agent, category: 'coding') }
    let!(:tier_1_agent) { create(:agent, tier: 1) }
    let!(:tier_5_agent) { create(:agent, tier: 5) }

    describe '.active' do
      it 'returns only active agents' do
        expect(Agent.active).to include(active_agent)
        expect(Agent.active).not_to include(inactive_agent)
      end
    end

    describe '.inactive' do
      it 'returns only inactive agents' do
        expect(Agent.inactive).to include(inactive_agent)
        expect(Agent.inactive).not_to include(active_agent)
      end
    end

    describe '.by_category' do
      it 'returns agents in specified category' do
        expect(Agent.by_category('research')).to include(research_agent)
        expect(Agent.by_category('research')).not_to include(coding_agent)
      end
    end

    describe '.by_tier' do
      it 'returns agents of specified tier' do
        expect(Agent.by_tier(1)).to include(tier_1_agent)
        expect(Agent.by_tier(1)).not_to include(tier_5_agent)
      end
    end

    describe '.by_number' do
      it 'orders agents by agent_number' do
        agents = Agent.by_number
        expect(agents.first.agent_number).to be <= agents.last.agent_number
      end
    end
  end

  describe '#status_badge_color' do
    it 'returns green for active' do
      agent = build(:agent, :active)
      expect(agent.status_badge_color).to eq('green')
    end

    it 'returns gray for inactive' do
      agent = build(:agent, :inactive)
      expect(agent.status_badge_color).to eq('gray')
    end

    it 'returns yellow for deprecated' do
      agent = build(:agent, :deprecated)
      expect(agent.status_badge_color).to eq('yellow')
    end

    it 'returns red for archived' do
      agent = build(:agent, :archived)
      expect(agent.status_badge_color).to eq('red')
    end

    it 'returns gray for unknown status' do
      agent = build(:agent)
      allow(agent).to receive(:status).and_return('unknown')
      expect(agent.status_badge_color).to eq('gray')
    end
  end

  describe '#tier_badge_color' do
    it 'returns correct colors for each tier' do
      expect(build(:agent, tier: 1).tier_badge_color).to eq('blue')
      expect(build(:agent, tier: 2).tier_badge_color).to eq('green')
      expect(build(:agent, tier: 3).tier_badge_color).to eq('yellow')
      expect(build(:agent, tier: 4).tier_badge_color).to eq('orange')
      expect(build(:agent, tier: 5).tier_badge_color).to eq('red')
    end

    it 'returns gray for invalid tier' do
      agent = build(:agent)
      allow(agent).to receive(:tier).and_return(99)
      expect(agent.tier_badge_color).to eq('gray')
    end
  end

  describe '#invocation_count' do
    it 'returns zero for agent with no invocations' do
      agent = create(:agent)
      expect(agent.invocation_count).to eq(0)
    end

    it 'returns correct count for agent with invocations' do
      agent = create(:agent, :with_invocations)
      expect(agent.invocation_count).to eq(5)
    end

    it 'updates count when invocations are added' do
      agent = create(:agent)
      expect(agent.invocation_count).to eq(0)
      create(:agent_invocation, agent: agent)
      expect(agent.invocation_count).to eq(1)
    end
  end

  describe '#recent_invocations' do
    let(:agent) { create(:agent) }

    it 'returns empty array for agent with no invocations' do
      expect(agent.recent_invocations).to be_empty
    end

    it 'returns most recent invocations' do
      old_invocation = create(:agent_invocation, agent: agent, started_at: 10.days.ago)
      recent_invocation = create(:agent_invocation, agent: agent, started_at: 1.day.ago)

      recent = agent.recent_invocations
      expect(recent.first).to eq(recent_invocation)
      expect(recent.last).to eq(old_invocation)
    end

    it 'limits results to 10 by default' do
      create_list(:agent_invocation, 15, agent: agent)
      expect(agent.recent_invocations.count).to eq(10)
    end

    it 'accepts custom limit' do
      create_list(:agent_invocation, 15, agent: agent)
      expect(agent.recent_invocations(5).count).to eq(5)
    end
  end

  describe '#open_issues_count' do
    let(:agent) { create(:agent) }

    it 'returns zero for agent with no issues' do
      expect(agent.open_issues_count).to eq(0)
    end

    it 'counts only open issues' do
      create(:agent_issue, :open, agent: agent)
      create(:agent_issue, :open, agent: agent)
      create(:agent_issue, :resolved, agent: agent)
      expect(agent.open_issues_count).to eq(2)
    end
  end

  describe '#pending_improvements_count' do
    let(:agent) { create(:agent) }

    it 'returns zero for agent with no improvements' do
      expect(agent.pending_improvements_count).to eq(0)
    end

    it 'counts only proposed improvements' do
      create(:agent_improvement, :proposed, agent: agent)
      create(:agent_improvement, :proposed, agent: agent)
      create(:agent_improvement, :implemented, agent: agent)
      expect(agent.pending_improvements_count).to eq(2)
    end
  end

  describe '#success_rate' do
    let(:agent) { create(:agent) }

    it 'returns 0 for agent with no invocations' do
      expect(agent.success_rate).to eq(0)
    end

    it 'returns 0 for agent with no completed invocations' do
      create(:agent_invocation, agent: agent, success: nil)
      expect(agent.success_rate).to eq(0)
    end

    it 'calculates success rate correctly' do
      create(:agent_invocation, agent: agent, success: true)
      create(:agent_invocation, agent: agent, success: true)
      create(:agent_invocation, agent: agent, success: false)
      expect(agent.success_rate).to eq(66.7)
    end

    it 'returns 100 for all successful invocations' do
      create_list(:agent_invocation, 5, agent: agent, success: true)
      expect(agent.success_rate).to eq(100.0)
    end

    it 'returns 0 for all failed invocations' do
      create_list(:agent_invocation, 5, agent: agent, success: false)
      expect(agent.success_rate).to eq(0.0)
    end

    it 'ignores invocations with nil success' do
      create(:agent_invocation, agent: agent, success: true)
      create(:agent_invocation, agent: agent, success: nil)
      expect(agent.success_rate).to eq(100.0)
    end
  end

  describe '#average_satisfaction' do
    let(:agent) { create(:agent) }

    it 'returns nil for agent with no ratings' do
      expect(agent.average_satisfaction).to be_nil
    end

    it 'returns nil for agent with no satisfaction ratings' do
      create(:agent_invocation, agent: agent, satisfaction_rating: nil)
      expect(agent.average_satisfaction).to be_nil
    end

    it 'calculates average correctly' do
      create(:agent_invocation, agent: agent, satisfaction_rating: 5)
      create(:agent_invocation, agent: agent, satisfaction_rating: 4)
      create(:agent_invocation, agent: agent, satisfaction_rating: 3)
      expect(agent.average_satisfaction).to eq(4.0)
    end

    it 'rounds to one decimal place' do
      create(:agent_invocation, agent: agent, satisfaction_rating: 5)
      create(:agent_invocation, agent: agent, satisfaction_rating: 4)
      expect(agent.average_satisfaction).to eq(4.5)
    end

    it 'ignores nil ratings in calculation' do
      create(:agent_invocation, agent: agent, satisfaction_rating: 5)
      create(:agent_invocation, agent: agent, satisfaction_rating: nil)
      expect(agent.average_satisfaction).to eq(5.0)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      agent = build(:agent)
      expect(agent).to be_valid
    end

    it 'creates agents with different agent_numbers' do
      agent1 = create(:agent)
      agent2 = create(:agent)
      expect(agent1.agent_number).not_to eq(agent2.agent_number)
    end

    context 'traits' do
      it 'creates active agents' do
        agent = create(:agent, :active)
        expect(agent.status).to eq('active')
      end

      it 'creates agents with invocations' do
        agent = create(:agent, :with_invocations)
        expect(agent.agent_invocations.count).to eq(5)
      end

      it 'creates fully populated agents' do
        agent = create(:agent, :fully_populated)
        expect(agent.agent_invocations.count).to eq(10)
        expect(agent.agent_issues.count).to eq(2)
        expect(agent.agent_improvements.count).to eq(3)
        expect(agent.agent_changes.count).to eq(5)
      end
    end
  end
end
