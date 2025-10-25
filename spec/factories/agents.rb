FactoryBot.define do
  factory :agent do
    sequence(:agent_number) { |n| n }
    sequence(:name) { |n| "Agent #{n}" }
    category { Agent::CATEGORIES.sample }
    tier { rand(1..5) }
    status { 'active' }

    # Trait for specific statuses
    trait :active do
      status { 'active' }
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :deprecated do
      status { 'deprecated' }
    end

    trait :archived do
      status { 'archived' }
    end

    # Trait for specific categories
    trait :research do
      category { 'research' }
    end

    trait :coding do
      category { 'coding' }
    end

    trait :testing do
      category { 'testing' }
    end

    trait :deployment do
      category { 'deployment' }
    end

    # Trait for specific tiers
    trait :tier_1 do
      tier { 1 }
    end

    trait :tier_5 do
      tier { 5 }
    end

    # Trait for agents with invocations
    trait :with_invocations do
      after(:create) do |agent|
        create_list(:agent_invocation, 5, agent: agent)
      end
    end

    # Trait for agents with successful invocations
    trait :with_successful_invocations do
      after(:create) do |agent|
        create_list(:agent_invocation, 3, agent: agent, success: true)
      end
    end

    # Trait for agents with failed invocations
    trait :with_failed_invocations do
      after(:create) do |agent|
        create_list(:agent_invocation, 2, agent: agent, success: false)
      end
    end

    # Trait for agents with issues
    trait :with_issues do
      after(:create) do |agent|
        create_list(:agent_issue, 3, agent: agent)
      end
    end

    # Trait for agents with improvements
    trait :with_improvements do
      after(:create) do |agent|
        create_list(:agent_improvement, 3, agent: agent)
      end
    end

    # Trait for agents with changes
    trait :with_changes do
      after(:create) do |agent|
        create_list(:agent_change, 5, agent: agent)
      end
    end

    # Trait for fully populated agent
    trait :fully_populated do
      after(:create) do |agent|
        create_list(:agent_invocation, 10, agent: agent)
        create_list(:agent_issue, 2, agent: agent)
        create_list(:agent_improvement, 3, agent: agent)
        create_list(:agent_change, 5, agent: agent)
      end
    end
  end
end
