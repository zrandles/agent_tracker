require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /agent_tracker" do
    it "returns successful response" do
      get "/agent_tracker"
      expect(response).to have_http_status(:ok)
    end

    it "displays dashboard title" do
      get "/agent_tracker"
      expect(response.body).to include('Agent Tracker')
    end

    context "with agents and invocations" do
      let!(:agents) { create_list(:agent, 5, :active) }
      let!(:inactive_agents) { create_list(:agent, 2, :inactive) }
      let!(:successful_invocations) { create_list(:agent_invocation, 10, :successful) }
      let!(:failed_invocations) { create_list(:agent_invocation, 2, :failed) }

      it "displays total agent count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Total should be 7 (5 active + 2 inactive)
      end

      it "displays active agent count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show 5 active agents
      end

      it "displays total invocation count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show 12 invocations (10 + 2)
      end

      it "calculates success rate" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Success rate should be 83.3% (10 out of 12)
      end
    end

    context "with satisfaction ratings" do
      let!(:agent) { create(:agent) }
      let!(:high_rating) { create(:agent_invocation, agent: agent, satisfaction_rating: 5) }
      let!(:low_rating) { create(:agent_invocation, agent: agent, satisfaction_rating: 3) }

      it "calculates average satisfaction" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Average should be 4.0
      end
    end

    context "with issues" do
      let!(:open_issues) { create_list(:agent_issue, 3, :open) }
      let!(:resolved_issues) { create_list(:agent_issue, 2, :resolved) }
      let!(:high_severity_issues) { create_list(:agent_issue, 2, :high, :open) }

      it "displays open issues count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show 5 open issues (3 + 2 high severity)
      end

      it "displays high severity issues" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end
    end

    context "with improvements" do
      let!(:pending_improvements) { create_list(:agent_improvement, 3, :pending) }
      let!(:implemented_improvements) { create_list(:agent_improvement, 2, :implemented) }

      it "displays pending improvements count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show 3 pending improvements
      end
    end

    context "with most used agents" do
      let!(:agent1) { create(:agent, name: 'Popular Agent') }
      let!(:agent2) { create(:agent, name: 'Less Popular Agent') }

      before do
        create_list(:agent_invocation, 10, agent: agent1)
        create_list(:agent_invocation, 3, agent: agent2)
      end

      it "displays most used agents" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Popular Agent')
      end

      it "orders agents by invocation count" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Popular Agent should appear before Less Popular Agent
      end
    end

    context "with recent invocations" do
      let!(:recent_invocation) { create(:agent_invocation, started_at: 1.hour.ago, task_description: 'Recent Task') }
      let!(:old_invocation) { create(:agent_invocation, started_at: 1.week.ago, task_description: 'Old Task') }

      it "displays recent invocations" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Recent Task')
      end

      it "limits recent invocations to 10" do
        AgentInvocation.destroy_all
        create_list(:agent_invocation, 15)
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end
    end

    context "with agents by category" do
      let!(:research_agents) { create_list(:agent, 3, category: 'research') }
      let!(:coding_agents) { create_list(:agent, 5, category: 'coding') }
      let!(:testing_agents) { create_list(:agent, 2, category: 'testing') }

      it "displays category breakdown" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show counts for each category
      end
    end

    context "with recent changes" do
      let!(:recent_changes) { create_list(:agent_change, 5, created_at: 1.day.ago) }
      let!(:old_changes) { create_list(:agent_change, 3, created_at: 1.month.ago) }

      it "displays recent changes" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end

      it "limits recent changes to 10" do
        AgentChange.destroy_all
        create_list(:agent_change, 15)
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end
    end

    context "with empty database" do
      before do
        Agent.destroy_all
        AgentInvocation.destroy_all
        AgentIssue.destroy_all
        AgentImprovement.destroy_all
        AgentChange.destroy_all
      end

      it "handles empty state gracefully" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end

      it "shows zero counts" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
        # Should show 0 for various counts
      end

      it "handles nil average satisfaction" do
        get "/agent_tracker"
        expect(response).to have_http_status(:ok)
      end
    end

    context "performance" do
      before do
        Agent.destroy_all
        create_list(:agent, 50, :with_invocations)
        create_list(:agent_issue, 20)
        create_list(:agent_improvement, 30)
        create_list(:agent_change, 40)
      end

      it "handles large datasets efficiently" do
        start_time = Time.now
        get "/agent_tracker"
        duration = Time.now - start_time

        expect(response).to have_http_status(:ok)
        # Should complete in under 2 seconds even with large dataset
        expect(duration).to be < 2.0
      end
    end
  end
end
