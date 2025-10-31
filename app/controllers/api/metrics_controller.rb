# Business Metrics API for App Monitor Integration
#
# Customized for Agent Tracker - AI agent invocation tracking
#
class Api::MetricsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_metrics_token, if: :token_required?

  def show
    render json: {
      app_name: detect_app_name,
      environment: Rails.env,
      timestamp: Time.current.iso8601,
      version: app_version,

      # Business metrics
      revenue: revenue_metrics,
      users: user_metrics,
      engagement: engagement_metrics,

      # Operational health
      health: health_metrics,

      # Agent tracking metrics
      custom: custom_metrics
    }
  rescue => e
    render json: {
      error: "Metrics collection failed",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :internal_server_error
  end

  private

  # No revenue tracking for infrastructure app
  def revenue_metrics
    nil
  end

  # No user accounts (agent-based usage)
  def user_metrics
    nil
  end

  # Key engagement metric: agent invocations
  def engagement_metrics
    {
      metric_name: "Agent Invocations (7 days)",
      metric_value: AgentInvocation.where("started_at > ?", 7.days.ago).count,
      metric_unit: "invocations",
      details: {
        today: AgentInvocation.where("started_at > ?", 1.day.ago).count,
        this_week: AgentInvocation.where("started_at > ?", 7.days.ago).count,
        this_month: AgentInvocation.where("started_at > ?", 30.days.ago).count
      }
    }
  end

  # Agent tracker specific metrics
  def custom_metrics
    {
      agents: {
        total: Agent.count,
        active_7d: Agent.joins(:agent_invocations)
                       .where("agent_invocations.started_at > ?", 7.days.ago)
                       .distinct.count,
        most_used: most_used_agent
      },
      invocations: {
        total: AgentInvocation.count,
        completed: AgentInvocation.completed.count,
        in_progress: AgentInvocation.in_progress.count,
        successful: AgentInvocation.successful.count,
        failed: AgentInvocation.failed.count,
        success_rate: calculate_success_rate
      },
      performance: {
        avg_duration_minutes: AgentInvocation.completed
                                            .where.not(duration_minutes: nil)
                                            .average(:duration_minutes)&.round(1),
        avg_satisfaction_rating: AgentInvocation.where.not(satisfaction_rating: nil)
                                               .average(:satisfaction_rating)&.round(2),
        total_tokens_used: AgentInvocation.sum(:tokens_total)
      },
      issues: {
        total: AgentIssue.count,
        unresolved: AgentIssue.where(resolved_at: nil).count,
        resolved_7d: AgentIssue.where("resolved_at > ?", 7.days.ago).count
      },
      improvements: {
        total: AgentImprovement.count,
        this_week: AgentImprovement.where("created_at > ?", 7.days.ago).count
      },
      activity: {
        invocations_today: AgentInvocation.where("started_at > ?", 1.day.ago).count,
        invocations_7d: AgentInvocation.where("started_at > ?", 7.days.ago).count,
        avg_invocations_per_day: calculate_avg_invocations_per_day
      }
    }
  end

  def most_used_agent
    agent_id = AgentInvocation.where("started_at > ?", 7.days.ago)
                              .group(:agent_id)
                              .count
                              .max_by { |_id, count| count }&.first

    return "None" unless agent_id
    Agent.find_by(id: agent_id)&.name || "Unknown"
  end

  def calculate_success_rate
    total = AgentInvocation.where.not(success: nil).count
    return 0 if total.zero?

    successful = AgentInvocation.successful.count
    ((successful.to_f / total) * 100).round(1)
  end

  def calculate_avg_invocations_per_day
    days = 7
    count = AgentInvocation.where("started_at > ?", days.days.ago).count
    (count.to_f / days).round(1)
  end

  # Health checks
  def health_metrics
    {
      database: database_connected?,
      cache: cache_connected?,
      jobs: jobs_healthy?,
      storage: storage_connected?
    }
  end

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue
    false
  end

  def cache_connected?
    Rails.cache.write("health_check", "ok", expires_in: 1.second)
    Rails.cache.read("health_check") == "ok"
  rescue
    false
  end

  def jobs_healthy?
    if defined?(SolidQueue)
      SolidQueue::Job.count >= 0
      true
    else
      nil
    end
  rescue
    false
  end

  def storage_connected?
    if defined?(ActiveStorage)
      ActiveStorage::Blob.count >= 0
      true
    else
      nil
    end
  rescue
    false
  end

  def app_version
    if File.exist?(Rails.root.join("VERSION"))
      File.read(Rails.root.join("VERSION")).strip
    elsif File.exist?(Rails.root.join(".git/refs/heads/main"))
      File.read(Rails.root.join(".git/refs/heads/main")).strip[0..7]
    else
      "unknown"
    end
  end

  # Security
  def token_required?
    Rails.env.production?
  end

  def verify_metrics_token
    expected_token = Rails.application.credentials.dig(:metrics_api_token)
    return true unless expected_token.present?

    provided_token = request.headers["Authorization"]&.gsub("Bearer ", "")

    unless provided_token == expected_token
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def detect_app_name
    if Rails.root.basename.to_s != "current"
      return Rails.root.basename.to_s
    end

    if Rails.root.to_s.include?("/home/zac/") && Rails.root.basename.to_s == "current"
      return Rails.root.parent.parent.basename.to_s
    end

    Rails.application.class.module_parent_name.underscore
  end
end
