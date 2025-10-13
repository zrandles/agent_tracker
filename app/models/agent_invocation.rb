class AgentInvocation < ApplicationRecord
  # Associations
  belongs_to :agent
  has_many :agent_issues, dependent: :nullify
  has_many :agent_changes, dependent: :nullify

  # Constants
  INVOCATION_MODES = %w[subagent manual].freeze

  # Validations
  validates :task_description, presence: true
  validates :invocation_mode, presence: true, inclusion: { in: INVOCATION_MODES }
  validates :started_at, presence: true
  validates :satisfaction_rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :tokens_input, :tokens_output, :tokens_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :calculate_duration

  # Scopes
  scope :recent, -> { order(started_at: :desc) }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :by_mode, ->(mode) { where(invocation_mode: mode) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }

  # Instance methods
  def mode_badge_color
    case invocation_mode
    when 'subagent' then 'purple'
    when 'manual' then 'blue'
    else 'gray'
    end
  end

  def success_badge_color
    case success
    when true then 'green'
    when false then 'red'
    else 'gray'
    end
  end

  def success_label
    case success
    when true then 'Success'
    when false then 'Failed'
    else 'Unknown'
    end
  end

  def rating_stars
    return '—' if satisfaction_rating.nil?
    '★' * satisfaction_rating + '☆' * (5 - satisfaction_rating)
  end

  def in_progress?
    completed_at.nil?
  end

  def completed?
    completed_at.present?
  end

  def duration_display
    return 'In progress' if duration_minutes.nil?
    if duration_minutes < 60
      "#{duration_minutes}m"
    else
      hours = duration_minutes / 60
      mins = duration_minutes % 60
      "#{hours}h #{mins}m"
    end
  end

  private

  def calculate_duration
    if started_at && completed_at
      self.duration_minutes = ((completed_at - started_at) / 60).round
    end
  end
end
