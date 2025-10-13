class Agent < ApplicationRecord
  # Associations
  has_many :agent_invocations, dependent: :destroy
  has_many :agent_issues, dependent: :destroy
  has_many :agent_improvements, dependent: :destroy
  has_many :agent_changes, dependent: :destroy

  # Constants
  STATUSES = %w[active inactive deprecated archived].freeze
  CATEGORIES = %w[
    research planning writing coding debugging deployment
    database testing monitoring analysis optimization security
    infrastructure documentation design marketing finance operations
  ].freeze
  TIERS = (1..5).to_a.freeze

  # Validations
  validates :agent_number, presence: true, uniqueness: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :tier, presence: true, inclusion: { in: TIERS }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_tier, ->(tier) { where(tier: tier) }
  scope :by_number, -> { order(:agent_number) }

  # Instance methods
  def status_badge_color
    case status
    when 'active' then 'green'
    when 'inactive' then 'gray'
    when 'deprecated' then 'yellow'
    when 'archived' then 'red'
    else 'gray'
    end
  end

  def tier_badge_color
    case tier
    when 1 then 'blue'
    when 2 then 'green'
    when 3 then 'yellow'
    when 4 then 'orange'
    when 5 then 'red'
    else 'gray'
    end
  end

  def invocation_count
    agent_invocations.count
  end

  def recent_invocations(limit = 10)
    agent_invocations.order(started_at: :desc).limit(limit)
  end

  def open_issues_count
    agent_issues.where(status: 'open').count
  end

  def pending_improvements_count
    agent_improvements.where(status: 'proposed').count
  end

  def success_rate
    invocations = agent_invocations.where.not(success: nil)
    return 0 if invocations.empty?
    (invocations.where(success: true).count.to_f / invocations.count * 100).round(1)
  end

  def average_satisfaction
    ratings = agent_invocations.where.not(satisfaction_rating: nil).pluck(:satisfaction_rating)
    return nil if ratings.empty?
    (ratings.sum.to_f / ratings.size).round(1)
  end
end
