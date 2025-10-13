class AgentIssue < ApplicationRecord
  # Associations
  belongs_to :agent
  belongs_to :agent_invocation, optional: true
  has_many :agent_changes, dependent: :nullify

  # Constants
  STATUSES = %w[open investigating resolved].freeze
  SEVERITIES = (1..5).to_a.freeze

  # Validations
  validates :issue_description, presence: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :open, -> { where(status: 'open') }
  scope :investigating, -> { where(status: 'investigating') }
  scope :resolved, -> { where(status: 'resolved') }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :high_severity, -> { where(severity: [4, 5]) }

  # Instance methods
  def status_badge_color
    case status
    when 'open' then 'red'
    when 'investigating' then 'yellow'
    when 'resolved' then 'green'
    else 'gray'
    end
  end

  def severity_badge_color
    case severity
    when 1 then 'blue'
    when 2 then 'green'
    when 3 then 'yellow'
    when 4 then 'orange'
    when 5 then 'red'
    else 'gray'
    end
  end

  def severity_label
    case severity
    when 1 then 'Minor'
    when 2 then 'Low'
    when 3 then 'Medium'
    when 4 then 'High'
    when 5 then 'Critical'
    else 'Unknown'
    end
  end

  def resolved?
    status == 'resolved'
  end

  def open?
    status == 'open'
  end
end
