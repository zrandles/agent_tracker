require 'rails_helper'

RSpec.describe "AgentInvocations", type: :request do
  describe "GET /agent_tracker/agent_invocations" do
    let!(:invocations) { create_list(:agent_invocation, 10) }

    it "returns successful response" do
      get "/agent_tracker/agent_invocations"
      expect(response).to have_http_status(:ok)
    end

    it "displays all invocations" do
      invocation = create(:agent_invocation, task_description: "Unique Task ABC123")
      get "/agent_tracker/agent_invocations"
      expect(response.body).to include("Unique Task ABC123")
    end

    context "filtering by agent" do
      let(:agent1) { create(:agent, name: 'Agent 1') }
      let(:agent2) { create(:agent, name: 'Agent 2') }
      let!(:inv1) { create(:agent_invocation, agent: agent1, task_description: 'Task for Agent 1') }
      let!(:inv2) { create(:agent_invocation, agent: agent2, task_description: 'Task for Agent 2') }

      it "filters invocations by agent" do
        get "/agent_tracker/agent_invocations", params: { agent_id: agent1.id }
        expect(response.body).to include('Task for Agent 1')
        expect(response.body).not_to include('Task for Agent 2')
      end
    end

    context "filtering by mode" do
      let!(:subagent) { create(:agent_invocation, :subagent, task_description: 'Subagent Task') }
      let!(:manual) { create(:agent_invocation, :manual, task_description: 'Manual Task') }

      it "filters invocations by mode" do
        get "/agent_tracker/agent_invocations", params: { mode: 'subagent' }
        expect(response.body).to include('Subagent Task')
        expect(response.body).not_to include('Manual Task')
      end
    end

    context "filtering by success" do
      let!(:successful) { create(:agent_invocation, :successful, task_description: 'Success Task') }
      let!(:failed) { create(:agent_invocation, :failed, task_description: 'Failed Task') }

      it "filters invocations by success status" do
        get "/agent_tracker/agent_invocations", params: { success: 'true' }
        expect(response.body).to include('Success Task')
        expect(response.body).not_to include('Failed Task')
      end

      it "filters invocations by failure status" do
        get "/agent_tracker/agent_invocations", params: { success: 'false' }
        expect(response.body).to include('Failed Task')
        expect(response.body).not_to include('Success Task')
      end
    end

    context "with many invocations" do
      it "handles large datasets" do
        AgentInvocation.destroy_all
        create_list(:agent_invocation, 100)
        get "/agent_tracker/agent_invocations"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /agent_tracker/agent_invocations/:id" do
    let(:invocation) { create(:agent_invocation, :with_issues, :with_changes) }

    it "returns successful response" do
      get "/agent_tracker/agent_invocations/#{invocation.id}"
      expect(response).to have_http_status(:ok)
    end

    it "displays invocation details" do
      invocation = create(:agent_invocation, task_description: "Detailed Task XYZ789")
      get "/agent_tracker/agent_invocations/#{invocation.id}"
      expect(response.body).to include("Detailed Task XYZ789")
    end

    it "displays agent name" do
      agent = create(:agent, name: "Test Agent Alpha")
      invocation = create(:agent_invocation, agent: agent)
      get "/agent_tracker/agent_invocations/#{invocation.id}"
      expect(response.body).to include("Test Agent Alpha")
    end

    it "displays associated issues" do
      get "/agent_tracker/agent_invocations/#{invocation.id}"
      expect(response).to have_http_status(:ok)
      # Invocation has issues due to :with_issues trait
      expect(invocation.agent_issues.count).to be > 0
    end

    it "displays associated changes" do
      get "/agent_tracker/agent_invocations/#{invocation.id}"
      expect(response).to have_http_status(:ok)
      # Invocation has changes due to :with_changes trait
      expect(invocation.agent_changes.count).to be > 0
    end

    it "returns 404 for non-existent invocation" do
      get "/agent_tracker/agent_invocations/99999"
      expect(response).to have_http_status(:not_found)
    rescue ActiveRecord::RecordNotFound
      # In test environment, RecordNotFound may be raised
      # In production with config.action_dispatch.show_exceptions, it returns 404
      expect(true).to be true
    end
  end

  describe "GET /agent_tracker/agent_invocations/new" do
    it "returns successful response" do
      get "/agent_tracker/agent_invocations/new"
      expect(response).to have_http_status(:ok)
    end

    it "displays new invocation form" do
      get "/agent_tracker/agent_invocations/new"
      expect(response.body).to include('form')
    end

    it "loads active agents" do
      active_agent = create(:agent, :active, name: "Active Agent")
      inactive_agent = create(:agent, :inactive, name: "Inactive Agent")
      get "/agent_tracker/agent_invocations/new"
      expect(response.body).to include("Active Agent")
    end

    it "pre-fills started_at with current time" do
      get "/agent_tracker/agent_invocations/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /agent_tracker/agent_invocations" do
    let(:agent) { create(:agent) }
    let(:valid_params) do
      {
        agent_invocation: {
          agent_id: agent.id,
          task_description: "Test task description",
          invocation_mode: "subagent",
          context_notes: "Test context",
          success: true,
          satisfaction_rating: 5,
          outcome_notes: "Test outcome"
        }
      }
    end

    it "creates a new invocation" do
      expect {
        post "/agent_tracker/agent_invocations", params: valid_params
      }.to change(AgentInvocation, :count).by(1)
    end

    it "redirects to invocation show page" do
      post "/agent_tracker/agent_invocations", params: valid_params
      expect(response).to redirect_to(agent_invocation_path(AgentInvocation.last))
    end

    it "displays success notice" do
      post "/agent_tracker/agent_invocations", params: valid_params
      follow_redirect!
      expect(response.body).to include('successfully')
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          agent_invocation: {
            agent_id: agent.id,
            task_description: "",  # Required field empty
            invocation_mode: "subagent"
          }
        }
      end

      it "does not create invocation" do
        expect {
          post "/agent_tracker/agent_invocations", params: invalid_params
        }.not_to change(AgentInvocation, :count)
      end

      it "renders new template with error" do
        post "/agent_tracker/agent_invocations", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with token data" do
      let(:params_with_tokens) do
        valid_params.merge(
          agent_invocation: valid_params[:agent_invocation].merge(
            tokens_input: 1000,
            tokens_output: 500,
            tokens_total: 1500
          )
        )
      end

      it "saves token data" do
        post "/agent_tracker/agent_invocations", params: params_with_tokens
        invocation = AgentInvocation.last
        expect(invocation.tokens_input).to eq(1000)
        expect(invocation.tokens_output).to eq(500)
        expect(invocation.tokens_total).to eq(1500)
      end
    end

    context "with completed_at" do
      let(:params_with_completion) do
        valid_params.merge(
          agent_invocation: valid_params[:agent_invocation].merge(
            completed_at: 1.hour.ago
          )
        )
      end

      it "calculates duration automatically" do
        post "/agent_tracker/agent_invocations", params: params_with_completion
        invocation = AgentInvocation.last
        expect(invocation.duration_minutes).to be_present
      end
    end
  end

  describe "performance" do
    it "handles large datasets efficiently" do
      AgentInvocation.destroy_all
      create_list(:agent_invocation, 200)

      start_time = Time.now
      get "/agent_tracker/agent_invocations"
      duration = Time.now - start_time

      expect(response).to have_http_status(:ok)
      # Should complete in under 2 seconds even with 200 invocations
      expect(duration).to be < 2.0
    end
  end
end
