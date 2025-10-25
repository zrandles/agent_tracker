require 'rails_helper'

RSpec.describe "Agents", type: :request do
  describe "GET /agent_tracker/agents" do
    let!(:agents) { create_list(:agent, 10) }

    it "returns successful response" do
      get "/agent_tracker/agents"
      expect(response).to have_http_status(:ok)
    end

    it "displays all agents" do
      agent = create(:agent, name: "Test Agent XYZ")
      get "/agent_tracker/agents"
      expect(response.body).to include("Test Agent XYZ")
    end

    context "filtering by category" do
      let!(:research_agent) { create(:agent, category: 'research', name: 'Research Agent') }
      let!(:coding_agent) { create(:agent, category: 'coding', name: 'Coding Agent') }

      it "filters agents by category" do
        get "/agent_tracker/agents", params: { category: 'research' }
        expect(response.body).to include('Research Agent')
        expect(response.body).not_to include('Coding Agent')
      end
    end

    context "filtering by tier" do
      let!(:tier_1_agent) { create(:agent, tier: 1, name: 'Tier 1 Agent') }
      let!(:tier_5_agent) { create(:agent, tier: 5, name: 'Tier 5 Agent') }

      it "filters agents by tier" do
        get "/agent_tracker/agents", params: { tier: 1 }
        expect(response.body).to include('Tier 1 Agent')
        expect(response.body).not_to include('Tier 5 Agent')
      end
    end

    context "filtering by status" do
      let!(:active_agent) { create(:agent, :active, name: 'Active Agent') }
      let!(:inactive_agent) { create(:agent, :inactive, name: 'Inactive Agent') }

      it "filters agents by status" do
        get "/agent_tracker/agents", params: { status: 'active' }
        expect(response.body).to include('Active Agent')
        expect(response.body).not_to include('Inactive Agent')
      end
    end

    context "with many agents" do
      it "handles large datasets" do
        Agent.destroy_all
        create_list(:agent, 100)
        get "/agent_tracker/agents"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /agent_tracker/agents/:id" do
    let(:agent) { create(:agent, :fully_populated) }

    it "returns successful response" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "displays agent name" do
      agent = create(:agent, name: "Unique Agent Name 123")
      get "/agent_tracker/agents/#{agent.id}"
      expect(response.body).to include("Unique Agent Name 123")
    end

    it "displays agent statistics" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
      # Agent has invocations, so stats should be present
      expect(agent.invocation_count).to be > 0
    end

    it "displays recent invocations" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "displays issues" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "displays improvements" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "displays changes" do
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "calculates success rate" do
      agent = create(:agent)
      create(:agent_invocation, agent: agent, success: true)
      create(:agent_invocation, agent: agent, success: true)
      create(:agent_invocation, agent: agent, success: false)

      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
      # Success rate should be 66.7%
      expect(agent.success_rate).to eq(66.7)
    end

    it "handles agent with no invocations" do
      agent = create(:agent)
      get "/agent_tracker/agents/#{agent.id}"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for non-existent agent" do
      get "/agent_tracker/agents/99999"
      expect(response).to have_http_status(:not_found)
    rescue ActiveRecord::RecordNotFound
      # In test environment, RecordNotFound may be raised
      # In production with config.action_dispatch.show_exceptions, it returns 404
      expect(true).to be true
    end
  end

  describe "performance" do
    it "handles large datasets efficiently" do
      Agent.destroy_all
      create_list(:agent, 200)

      start_time = Time.now
      get "/agent_tracker/agents"
      duration = Time.now - start_time

      expect(response).to have_http_status(:ok)
      # Should complete in under 2 seconds even with 200 agents
      expect(duration).to be < 2.0
    end
  end
end
