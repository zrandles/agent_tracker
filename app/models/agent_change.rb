class AgentChange < ApplicationRecord
  # Associations
  belongs_to :agent
  belongs_to :agent_invocation, optional: true
  belongs_to :agent_issue, optional: true
  belongs_to :agent_improvement, optional: true

  # Constants
  CHANGE_TYPES = %w[
    spec_update context_update example_added status_change
    subagent_integration bug_fix capability_added capability_removed
  ].freeze

  TRIGGERED_BY = %w[
    invocation_issue user_request improvement refactor initial_creation
  ].freeze

  # Validations
  validates :change_type, presence: true, inclusion: { in: CHANGE_TYPES }
  validates :change_description, presence: true
  validates :triggered_by, presence: true, inclusion: { in: TRIGGERED_BY }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(change_type: type) }
  scope :by_trigger, ->(trigger) { where(triggered_by: trigger) }

  # Instance methods
  def change_type_label
    change_type.humanize
  end

  def triggered_by_label
    triggered_by.humanize
  end

  def change_type_badge_color
    case change_type
    when 'spec_update', 'context_update' then 'blue'
    when 'example_added' then 'green'
    when 'status_change' then 'yellow'
    when 'bug_fix' then 'red'
    when 'capability_added' then 'green'
    when 'capability_removed' then 'orange'
    when 'subagent_integration' then 'purple'
    else 'gray'
    end
  end

  def triggered_by_badge_color
    case triggered_by
    when 'invocation_issue' then 'red'
    when 'user_request' then 'blue'
    when 'improvement' then 'green'
    when 'refactor' then 'yellow'
    when 'initial_creation' then 'purple'
    else 'gray'
    end
  end

  def has_value_change?
    before_value.present? || after_value.present?
  end
end
