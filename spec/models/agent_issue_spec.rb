require 'rails_helper'

RSpec.describe AgentIssue, type: :model do
  describe 'associations' do
    it { should belong_to(:agent) }
    it { should belong_to(:agent_invocation).optional }
    it { should have_many(:agent_changes).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:issue_description) }
    it { should validate_presence_of(:severity) }
    it { should validate_presence_of(:status) }

    it { should validate_inclusion_of(:severity).in_array(AgentIssue::SEVERITIES) }
    it { should validate_inclusion_of(:status).in_array(AgentIssue::STATUSES) }

    context 'severity validation' do
      it 'accepts valid severities' do
        (1..5).each do |severity|
          issue = build(:agent_issue, severity: severity)
          expect(issue).to be_valid
        end
      end

      it 'rejects severity 0' do
        issue = build(:agent_issue, severity: 0)
        expect(issue).not_to be_valid
      end

      it 'rejects severity 6' do
        issue = build(:agent_issue, severity: 6)
        expect(issue).not_to be_valid
      end
    end

    context 'status validation' do
      it 'accepts valid statuses' do
        AgentIssue::STATUSES.each do |status|
          issue = build(:agent_issue, status: status)
          expect(issue).to be_valid
        end
      end

      it 'rejects invalid statuses' do
        issue = build(:agent_issue, status: 'invalid')
        expect(issue).not_to be_valid
      end
    end
  end

  describe 'constants' do
    it 'has correct STATUSES' do
      expect(AgentIssue::STATUSES).to eq(%w[open investigating resolved])
    end

    it 'has correct SEVERITIES' do
      expect(AgentIssue::SEVERITIES).to eq([1, 2, 3, 4, 5])
    end
  end

  describe 'scopes' do
    let!(:old_issue) { create(:agent_issue, created_at: 1.month.ago) }
    let!(:recent_issue) { create(:agent_issue, created_at: 1.day.ago) }
    let!(:open_issue) { create(:agent_issue, :open) }
    let!(:investigating_issue) { create(:agent_issue, :investigating) }
    let!(:resolved_issue) { create(:agent_issue, :resolved) }
    let!(:high_severity) { create(:agent_issue, :high) }
    let!(:critical_severity) { create(:agent_issue, :critical) }
    let!(:low_severity) { create(:agent_issue, :low) }

    describe '.recent' do
      it 'orders by created_at descending' do
        issues = AgentIssue.where(id: [recent_issue.id, old_issue.id]).recent
        expect(issues.first.id).to eq(recent_issue.id)
        expect(issues.last.id).to eq(old_issue.id)
      end
    end

    describe '.open' do
      it 'returns only open issues' do
        expect(AgentIssue.open).to include(open_issue)
        expect(AgentIssue.open).not_to include(resolved_issue)
      end
    end

    describe '.investigating' do
      it 'returns only investigating issues' do
        expect(AgentIssue.investigating).to include(investigating_issue)
        expect(AgentIssue.investigating).not_to include(open_issue)
      end
    end

    describe '.resolved' do
      it 'returns only resolved issues' do
        expect(AgentIssue.resolved).to include(resolved_issue)
        expect(AgentIssue.resolved).not_to include(open_issue)
      end
    end

    describe '.by_severity' do
      it 'returns issues of specified severity' do
        expect(AgentIssue.by_severity(4)).to include(high_severity)
        expect(AgentIssue.by_severity(4)).not_to include(critical_severity)
      end
    end

    describe '.high_severity' do
      it 'returns only high and critical severity issues' do
        expect(AgentIssue.high_severity).to include(high_severity, critical_severity)
        expect(AgentIssue.high_severity).not_to include(low_severity)
      end
    end
  end

  describe '#status_badge_color' do
    it 'returns red for open' do
      issue = build(:agent_issue, :open)
      expect(issue.status_badge_color).to eq('red')
    end

    it 'returns yellow for investigating' do
      issue = build(:agent_issue, :investigating)
      expect(issue.status_badge_color).to eq('yellow')
    end

    it 'returns green for resolved' do
      issue = build(:agent_issue, :resolved)
      expect(issue.status_badge_color).to eq('green')
    end

    it 'returns gray for unknown status' do
      issue = build(:agent_issue)
      allow(issue).to receive(:status).and_return('unknown')
      expect(issue.status_badge_color).to eq('gray')
    end
  end

  describe '#severity_badge_color' do
    it 'returns correct colors for each severity' do
      expect(build(:agent_issue, severity: 1).severity_badge_color).to eq('blue')
      expect(build(:agent_issue, severity: 2).severity_badge_color).to eq('green')
      expect(build(:agent_issue, severity: 3).severity_badge_color).to eq('yellow')
      expect(build(:agent_issue, severity: 4).severity_badge_color).to eq('orange')
      expect(build(:agent_issue, severity: 5).severity_badge_color).to eq('red')
    end

    it 'returns gray for invalid severity' do
      issue = build(:agent_issue)
      allow(issue).to receive(:severity).and_return(99)
      expect(issue.severity_badge_color).to eq('gray')
    end
  end

  describe '#severity_label' do
    it 'returns correct labels for each severity' do
      expect(build(:agent_issue, severity: 1).severity_label).to eq('Minor')
      expect(build(:agent_issue, severity: 2).severity_label).to eq('Low')
      expect(build(:agent_issue, severity: 3).severity_label).to eq('Medium')
      expect(build(:agent_issue, severity: 4).severity_label).to eq('High')
      expect(build(:agent_issue, severity: 5).severity_label).to eq('Critical')
    end

    it 'returns Unknown for invalid severity' do
      issue = build(:agent_issue)
      allow(issue).to receive(:severity).and_return(99)
      expect(issue.severity_label).to eq('Unknown')
    end
  end

  describe '#resolved?' do
    it 'returns true when status is resolved' do
      issue = build(:agent_issue, :resolved)
      expect(issue.resolved?).to be true
    end

    it 'returns false when status is not resolved' do
      issue = build(:agent_issue, :open)
      expect(issue.resolved?).to be false
    end
  end

  describe '#open?' do
    it 'returns true when status is open' do
      issue = build(:agent_issue, :open)
      expect(issue.open?).to be true
    end

    it 'returns false when status is not open' do
      issue = build(:agent_issue, :resolved)
      expect(issue.open?).to be false
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      issue = build(:agent_issue)
      expect(issue).to be_valid
    end

    it 'creates issues with different descriptions' do
      issue1 = create(:agent_issue)
      issue2 = create(:agent_issue)
      expect(issue1.issue_description).not_to eq(issue2.issue_description)
    end

    context 'traits' do
      it 'creates open issues' do
        issue = create(:agent_issue, :open)
        expect(issue.status).to eq('open')
      end

      it 'creates critical issues' do
        issue = create(:agent_issue, :critical)
        expect(issue.severity).to eq(5)
      end

      it 'creates issues with changes' do
        issue = create(:agent_issue, :with_changes)
        expect(issue.agent_changes.count).to eq(2)
      end
    end
  end
end
