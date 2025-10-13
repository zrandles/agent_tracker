class AgentInvocationsController < ApplicationController
  def index
    @invocations = AgentInvocation.includes(:agent).recent

    # Filter by agent
    if params[:agent_id].present?
      @invocations = @invocations.where(agent_id: params[:agent_id])
    end

    # Filter by mode
    if params[:mode].present?
      @invocations = @invocations.where(invocation_mode: params[:mode])
    end

    # Filter by success
    if params[:success].present?
      @invocations = @invocations.where(success: params[:success] == 'true')
    end

    @invocations = @invocations.page(params[:page]).per(25) if defined?(Kaminari)
  end

  def show
    @invocation = AgentInvocation.includes(:agent, :agent_issues, :agent_changes).find(params[:id])
  end

  def new
    @invocation = AgentInvocation.new
    @invocation.started_at = Time.current
    @agents = Agent.active.order(:name)
  end

  def create
    @invocation = AgentInvocation.new(invocation_params)
    @invocation.started_at ||= Time.current

    if @invocation.save
      redirect_to agent_invocation_path(@invocation), notice: 'Invocation logged successfully!'
    else
      @agents = Agent.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def invocation_params
    params.require(:agent_invocation).permit(
      :agent_id, :task_description, :invocation_mode, :context_notes,
      :started_at, :completed_at, :success, :satisfaction_rating,
      :outcome_notes, :tokens_input, :tokens_output, :tokens_total
    )
  end
end
