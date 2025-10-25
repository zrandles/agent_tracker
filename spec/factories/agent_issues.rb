FactoryBot.define do
  factory :agent_issue do
    association :agent
    agent_invocation { nil }
    sequence(:issue_description) { |n| "Issue #{n}: Error encountered during execution" }
    severity { rand(1..5) }
    status { 'open' }
    resolution_notes { nil }

    # Trait for different statuses
    trait :open do
      status { 'open' }
      resolution_notes { nil }
    end

    trait :investigating do
      status { 'investigating' }
      resolution_notes { 'Currently investigating the root cause' }
    end

    trait :resolved do
      status { 'resolved' }
      resolution_notes { 'Issue has been resolved by updating the agent spec' }
    end

    # Trait for different severity levels
    trait :minor do
      severity { 1 }
    end

    trait :low do
      severity { 2 }
    end

    trait :medium do
      severity { 3 }
    end

    trait :high do
      severity { 4 }
    end

    trait :critical do
      severity { 5 }
    end

    # Trait for high severity issues
    trait :high_severity do
      severity { [4, 5].sample }
    end

    # Trait for low severity issues
    trait :low_severity do
      severity { [1, 2].sample }
    end

    # Trait with agent invocation
    trait :with_invocation do
      association :agent_invocation
    end

    # Trait without agent invocation
    trait :without_invocation do
      agent_invocation { nil }
    end

    # Trait with associated changes
    trait :with_changes do
      after(:create) do |issue|
        create_list(:agent_change, 2, agent_issue: issue, agent: issue.agent)
      end
    end

    # Trait for recently created issues
    trait :recent do
      created_at { 1.day.ago }
    end

    # Trait for old issues
    trait :old do
      created_at { 30.days.ago }
    end
  end
end
