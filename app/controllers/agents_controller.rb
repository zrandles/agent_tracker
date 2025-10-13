class AgentsController < ApplicationController
  def index
    @agents = Agent.by_number

    # Filter by category
    if params[:category].present?
      @agents = @agents.where(category: params[:category])
    end

    # Filter by tier
    if params[:tier].present?
      @agents = @agents.where(tier: params[:tier])
    end

    # Filter by status
    if params[:status].present?
      @agents = @agents.where(status: params[:status])
    end

    @agents = @agents.page(params[:page]).per(50) if defined?(Kaminari)
  end

  def show
    @agent = Agent.find(params[:id])
    @invocations = @agent.agent_invocations.recent.limit(20)
    @issues = @agent.agent_issues.recent.limit(10)
    @improvements = @agent.agent_improvements.recent.limit(10)
    @changes = @agent.agent_changes.recent.limit(15)

    # Stats
    @total_invocations = @agent.invocation_count
    @success_rate = @agent.success_rate
    @average_satisfaction = @agent.average_satisfaction
    @open_issues = @agent.open_issues_count
    @pending_improvements = @agent.pending_improvements_count
  end
end
