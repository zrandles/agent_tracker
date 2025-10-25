require 'rails_helper'

RSpec.describe AgentInvocation, type: :model do
  describe 'associations' do
    it { should belong_to(:agent) }
    it { should have_many(:agent_issues).dependent(:nullify) }
    it { should have_many(:agent_changes).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:task_description) }
    it { should validate_presence_of(:invocation_mode) }
    it { should validate_presence_of(:started_at) }

    it { should validate_inclusion_of(:invocation_mode).in_array(AgentInvocation::INVOCATION_MODES) }

    context 'satisfaction_rating validation' do
      it { should validate_numericality_of(:satisfaction_rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5).allow_nil }

      it 'allows nil satisfaction_rating' do
        invocation = build(:agent_invocation, satisfaction_rating: nil)
        expect(invocation).to be_valid
      end

      it 'accepts valid ratings' do
        (1..5).each do |rating|
          invocation = build(:agent_invocation, satisfaction_rating: rating)
          expect(invocation).to be_valid
        end
      end

      it 'rejects rating below 1' do
        invocation = build(:agent_invocation, satisfaction_rating: 0)
        expect(invocation).not_to be_valid
      end

      it 'rejects rating above 5' do
        invocation = build(:agent_invocation, satisfaction_rating: 6)
        expect(invocation).not_to be_valid
      end
    end

    context 'token validations' do
      it { should validate_numericality_of(:tokens_input).only_integer.is_greater_than_or_equal_to(0).allow_nil }
      it { should validate_numericality_of(:tokens_output).only_integer.is_greater_than_or_equal_to(0).allow_nil }
      it { should validate_numericality_of(:tokens_total).only_integer.is_greater_than_or_equal_to(0).allow_nil }

      it 'allows nil token values' do
        invocation = build(:agent_invocation, :no_token_data)
        expect(invocation).to be_valid
      end

      it 'rejects negative tokens' do
        invocation = build(:agent_invocation, tokens_input: -1)
        expect(invocation).not_to be_valid
      end
    end
  end

  describe 'constants' do
    it 'has correct INVOCATION_MODES' do
      expect(AgentInvocation::INVOCATION_MODES).to eq(%w[subagent manual])
    end
  end

  describe 'scopes' do
    let!(:recent_invocation) { create(:agent_invocation, started_at: 1.hour.ago) }
    let!(:old_invocation) { create(:agent_invocation, started_at: 1.week.ago) }
    let!(:successful) { create(:agent_invocation, :successful) }
    let!(:failed) { create(:agent_invocation, :failed) }
    let!(:subagent) { create(:agent_invocation, :subagent) }
    let!(:manual) { create(:agent_invocation, :manual) }
    let!(:completed) { create(:agent_invocation, :completed) }
    let!(:in_progress) { create(:agent_invocation, :in_progress) }

    describe '.recent' do
      it 'orders by started_at descending' do
        invocations = AgentInvocation.recent
        expect(invocations.first).to eq(recent_invocation)
        expect(invocations.last).to eq(old_invocation)
      end
    end

    describe '.successful' do
      it 'returns only successful invocations' do
        expect(AgentInvocation.successful).to include(successful)
        expect(AgentInvocation.successful).not_to include(failed)
      end
    end

    describe '.failed' do
      it 'returns only failed invocations' do
        expect(AgentInvocation.failed).to include(failed)
        expect(AgentInvocation.failed).not_to include(successful)
      end
    end

    describe '.by_mode' do
      it 'returns invocations of specified mode' do
        expect(AgentInvocation.by_mode('subagent')).to include(subagent)
        expect(AgentInvocation.by_mode('subagent')).not_to include(manual)
      end
    end

    describe '.completed' do
      it 'returns only completed invocations' do
        expect(AgentInvocation.completed).to include(completed)
        expect(AgentInvocation.completed).not_to include(in_progress)
      end
    end

    describe '.in_progress' do
      it 'returns only in-progress invocations' do
        expect(AgentInvocation.in_progress).to include(in_progress)
        expect(AgentInvocation.in_progress).not_to include(completed)
      end
    end
  end

  describe 'callbacks' do
    describe '#calculate_duration' do
      it 'calculates duration on save when both times are present' do
        invocation = create(:agent_invocation,
                           started_at: 2.hours.ago,
                           completed_at: 1.hour.ago)
        expect(invocation.duration_minutes).to eq(60)
      end

      it 'does not calculate duration when completed_at is nil' do
        invocation = create(:agent_invocation, :in_progress)
        expect(invocation.duration_minutes).to be_nil
      end

      it 'recalculates duration when times change' do
        invocation = create(:agent_invocation,
                           started_at: 2.hours.ago,
                           completed_at: 1.hour.ago)
        expect(invocation.duration_minutes).to eq(60)

        invocation.update(completed_at: 30.minutes.ago)
        expect(invocation.duration_minutes).to eq(90)
      end

      it 'rounds duration to nearest minute' do
        invocation = create(:agent_invocation,
                           started_at: Time.zone.parse('2025-01-01 10:00:00'),
                           completed_at: Time.zone.parse('2025-01-01 10:30:30'))
        expect(invocation.duration_minutes).to eq(31)
      end
    end
  end

  describe '#mode_badge_color' do
    it 'returns purple for subagent' do
      invocation = build(:agent_invocation, :subagent)
      expect(invocation.mode_badge_color).to eq('purple')
    end

    it 'returns blue for manual' do
      invocation = build(:agent_invocation, :manual)
      expect(invocation.mode_badge_color).to eq('blue')
    end

    it 'returns gray for unknown mode' do
      invocation = build(:agent_invocation)
      allow(invocation).to receive(:invocation_mode).and_return('unknown')
      expect(invocation.mode_badge_color).to eq('gray')
    end
  end

  describe '#success_badge_color' do
    it 'returns green for success' do
      invocation = build(:agent_invocation, success: true)
      expect(invocation.success_badge_color).to eq('green')
    end

    it 'returns red for failure' do
      invocation = build(:agent_invocation, success: false)
      expect(invocation.success_badge_color).to eq('red')
    end

    it 'returns gray for unknown' do
      invocation = build(:agent_invocation, success: nil)
      expect(invocation.success_badge_color).to eq('gray')
    end
  end

  describe '#success_label' do
    it 'returns Success for true' do
      invocation = build(:agent_invocation, success: true)
      expect(invocation.success_label).to eq('Success')
    end

    it 'returns Failed for false' do
      invocation = build(:agent_invocation, success: false)
      expect(invocation.success_label).to eq('Failed')
    end

    it 'returns Unknown for nil' do
      invocation = build(:agent_invocation, success: nil)
      expect(invocation.success_label).to eq('Unknown')
    end
  end

  describe '#rating_stars' do
    it 'returns correct stars for rating' do
      expect(build(:agent_invocation, satisfaction_rating: 1).rating_stars).to eq('★☆☆☆☆')
      expect(build(:agent_invocation, satisfaction_rating: 2).rating_stars).to eq('★★☆☆☆')
      expect(build(:agent_invocation, satisfaction_rating: 3).rating_stars).to eq('★★★☆☆')
      expect(build(:agent_invocation, satisfaction_rating: 4).rating_stars).to eq('★★★★☆')
      expect(build(:agent_invocation, satisfaction_rating: 5).rating_stars).to eq('★★★★★')
    end

    it 'returns — for nil rating' do
      invocation = build(:agent_invocation, satisfaction_rating: nil)
      expect(invocation.rating_stars).to eq('—')
    end
  end

  describe '#in_progress?' do
    it 'returns true when completed_at is nil' do
      invocation = build(:agent_invocation, :in_progress)
      expect(invocation.in_progress?).to be true
    end

    it 'returns false when completed_at is present' do
      invocation = build(:agent_invocation, :completed)
      expect(invocation.in_progress?).to be false
    end
  end

  describe '#completed?' do
    it 'returns true when completed_at is present' do
      invocation = build(:agent_invocation, :completed)
      expect(invocation.completed?).to be true
    end

    it 'returns false when completed_at is nil' do
      invocation = build(:agent_invocation, :in_progress)
      expect(invocation.completed?).to be false
    end
  end

  describe '#duration_display' do
    it 'returns "In progress" when duration is nil' do
      invocation = build(:agent_invocation, :in_progress)
      expect(invocation.duration_display).to eq('In progress')
    end

    it 'displays minutes for durations under 60 minutes' do
      invocation = build(:agent_invocation, duration_minutes: 45)
      expect(invocation.duration_display).to eq('45m')
    end

    it 'displays hours and minutes for durations over 60 minutes' do
      invocation = build(:agent_invocation, duration_minutes: 125)
      expect(invocation.duration_display).to eq('2h 5m')
    end

    it 'displays only hours when minutes is zero' do
      invocation = build(:agent_invocation, duration_minutes: 120)
      expect(invocation.duration_display).to eq('2h 0m')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      invocation = build(:agent_invocation)
      expect(invocation).to be_valid
    end

    it 'creates invocations with different task descriptions' do
      inv1 = create(:agent_invocation)
      inv2 = create(:agent_invocation)
      expect(inv1.task_description).not_to eq(inv2.task_description)
    end

    context 'traits' do
      it 'creates successful invocations' do
        invocation = create(:agent_invocation, :successful)
        expect(invocation.success).to be true
        expect(invocation.completed_at).to be_present
      end

      it 'creates in-progress invocations' do
        invocation = create(:agent_invocation, :in_progress)
        expect(invocation.completed_at).to be_nil
        expect(invocation.in_progress?).to be true
      end

      it 'creates invocations with issues' do
        invocation = create(:agent_invocation, :with_issues)
        expect(invocation.agent_issues.count).to eq(2)
      end

      it 'creates invocations with changes' do
        invocation = create(:agent_invocation, :with_changes)
        expect(invocation.agent_changes.count).to eq(3)
      end
    end
  end
end
