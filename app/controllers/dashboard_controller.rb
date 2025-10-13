class DashboardController < ApplicationController
  def index
    @total_agents = Agent.count
    @active_agents = Agent.active.count
    @total_invocations = AgentInvocation.count
    @recent_invocations = AgentInvocation.recent.limit(10)

    # Success metrics
    @success_rate = calculate_success_rate
    @average_satisfaction = calculate_average_satisfaction

    # Most used agents (top 10 by invocation count)
    @most_used_agents = Agent.joins(:agent_invocations)
                             .select('agents.*, COUNT(agent_invocations.id) as invocations_count')
                             .group('agents.id')
                             .order('invocations_count DESC')
                             .limit(10)

    # Issues and improvements
    @open_issues_count = AgentIssue.open.count
    @high_severity_issues = AgentIssue.high_severity.open.limit(5)
    @pending_improvements_count = AgentImprovement.pending.count

    # Category breakdown
    @agents_by_category = Agent.group(:category).count

    # Recent changes
    @recent_changes = AgentChange.recent.limit(10).includes(:agent)
  end

  private

  def calculate_success_rate
    invocations = AgentInvocation.where.not(success: nil)
    return 0 if invocations.empty?
    (invocations.where(success: true).count.to_f / invocations.count * 100).round(1)
  end

  def calculate_average_satisfaction
    ratings = AgentInvocation.where.not(satisfaction_rating: nil).pluck(:satisfaction_rating)
    return nil if ratings.empty?
    (ratings.sum.to_f / ratings.size).round(1)
  end
end
