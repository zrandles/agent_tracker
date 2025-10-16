module Api
  class AgentInvocationsController < ApplicationController
    # Skip CSRF for API requests (we'll use token auth instead)
    skip_before_action :verify_authenticity_token

    before_action :authenticate_api_token

    # POST /api/agent_invocations/bulk_create
    # Creates multiple agent invocations in a single request
    #
    # Expected format:
    # {
    #   "invocations": [
    #     {
    #       "agent_number": 2,
    #       "task_description": "Research idea",
    #       "invocation_mode": "subagent",
    #       "context_notes": "idea_tracker - validation",
    #       "started_at": "2025-10-16T21:00:00Z",
    #       "completed_at": "2025-10-16T21:15:00Z",
    #       "duration_minutes": 15,
    #       "success": true,
    #       "satisfaction_rating": 5,
    #       "outcome_notes": "Comprehensive report generated"
    #     }
    #   ]
    # }
    def bulk_create
      invocations_data = params.require(:invocations)

      created_invocations = []
      errors = []

      ActiveRecord::Base.transaction do
        invocations_data.each_with_index do |inv_data, index|
          begin
            # Find agent by agent_number
            agent = Agent.find_by!(agent_number: inv_data[:agent_number])

            # Build invocation
            invocation = AgentInvocation.new(
              agent: agent,
              task_description: inv_data[:task_description],
              invocation_mode: inv_data[:invocation_mode] || 'subagent',
              context_notes: inv_data[:context_notes],
              started_at: Time.parse(inv_data[:started_at]),
              completed_at: Time.parse(inv_data[:completed_at]),
              duration_minutes: inv_data[:duration_minutes],
              success: inv_data[:success],
              satisfaction_rating: inv_data[:satisfaction_rating],
              outcome_notes: inv_data[:outcome_notes]
            )

            if invocation.save
              created_invocations << invocation
            else
              errors << { index: index, errors: invocation.errors.full_messages }
              raise ActiveRecord::Rollback
            end
          rescue ActiveRecord::RecordNotFound => e
            errors << { index: index, error: "Agent not found with agent_number: #{inv_data[:agent_number]}" }
            raise ActiveRecord::Rollback
          rescue => e
            errors << { index: index, error: e.message }
            raise ActiveRecord::Rollback
          end
        end
      end

      if errors.empty?
        render json: {
          success: true,
          created_count: created_invocations.size,
          invocations: created_invocations.map { |i| { id: i.id, task_description: i.task_description } }
        }, status: :created
      else
        render json: {
          success: false,
          errors: errors
        }, status: :unprocessable_entity
      end
    end

    private

    def authenticate_api_token
      token = request.headers['Authorization']&.sub('Bearer ', '')

      # Get expected token from environment or credentials
      expected_token = Rails.application.credentials.dig(:api, :agent_tracker_token) ||
                      ENV['AGENT_TRACKER_API_TOKEN']

      unless expected_token.present?
        render json: { error: 'API not configured' }, status: :internal_server_error
        return
      end

      unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, expected_token.to_s)
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
