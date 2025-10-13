class AgentImprovement < ApplicationRecord
  # Associations
  belongs_to :agent
  has_many :agent_changes, dependent: :nullify

  # Constants
  STATUSES = %w[proposed approved implemented rejected].freeze
  PRIORITIES = (1..5).to_a.freeze

  # Validations
  validates :improvement_description, presence: true
  validates :priority, presence: true, inclusion: { in: PRIORITIES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Callbacks
  before_save :set_implemented_at

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :proposed, -> { where(status: 'proposed') }
  scope :approved, -> { where(status: 'approved') }
  scope :implemented, -> { where(status: 'implemented') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :high_priority, -> { where(priority: [4, 5]) }
  scope :pending, -> { where(status: ['proposed', 'approved']) }

  # Instance methods
  def status_badge_color
    case status
    when 'proposed' then 'blue'
    when 'approved' then 'yellow'
    when 'implemented' then 'green'
    when 'rejected' then 'red'
    else 'gray'
    end
  end

  def priority_badge_color
    case priority
    when 1 then 'blue'
    when 2 then 'green'
    when 3 then 'yellow'
    when 4 then 'orange'
    when 5 then 'red'
    else 'gray'
    end
  end

  def priority_label
    case priority
    when 1 then 'Very Low'
    when 2 then 'Low'
    when 3 then 'Medium'
    when 4 then 'High'
    when 5 then 'Critical'
    else 'Unknown'
    end
  end

  def implemented?
    status == 'implemented'
  end

  def pending?
    ['proposed', 'approved'].include?(status)
  end

  private

  def set_implemented_at
    if status == 'implemented' && status_changed? && implemented_at.nil?
      self.implemented_at = Time.current
    end
  end
end
