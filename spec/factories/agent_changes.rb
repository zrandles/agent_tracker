FactoryBot.define do
  factory :agent_change do
    association :agent
    agent_invocation { nil }
    agent_issue { nil }
    agent_improvement { nil }
    change_type { AgentChange::CHANGE_TYPES.sample }
    sequence(:change_description) { |n| "Change #{n}: Updated agent specification" }
    triggered_by { AgentChange::TRIGGERED_BY.sample }
    before_value { nil }
    after_value { nil }

    # Trait for different change types
    trait :spec_update do
      change_type { 'spec_update' }
      change_description { 'Updated agent specification' }
    end

    trait :context_update do
      change_type { 'context_update' }
      change_description { 'Updated agent context' }
    end

    trait :example_added do
      change_type { 'example_added' }
      change_description { 'Added new example to agent' }
    end

    trait :status_change do
      change_type { 'status_change' }
      change_description { 'Changed agent status' }
      before_value { 'active' }
      after_value { 'inactive' }
    end

    trait :bug_fix do
      change_type { 'bug_fix' }
      change_description { 'Fixed bug in agent logic' }
    end

    trait :capability_added do
      change_type { 'capability_added' }
      change_description { 'Added new capability to agent' }
    end

    trait :capability_removed do
      change_type { 'capability_removed' }
      change_description { 'Removed deprecated capability' }
    end

    trait :subagent_integration do
      change_type { 'subagent_integration' }
      change_description { 'Integrated with subagent' }
    end

    # Trait for different triggers
    trait :invocation_issue do
      triggered_by { 'invocation_issue' }
      association :agent_issue
    end

    trait :user_request do
      triggered_by { 'user_request' }
    end

    trait :improvement do
      triggered_by { 'improvement' }
      association :agent_improvement
    end

    trait :refactor do
      triggered_by { 'refactor' }
    end

    trait :initial_creation do
      triggered_by { 'initial_creation' }
    end

    # Trait with value changes
    trait :with_value_changes do
      before_value { 'old value' }
      after_value { 'new value' }
    end

    # Trait without value changes
    trait :without_value_changes do
      before_value { nil }
      after_value { nil }
    end

    # Trait with all associations
    trait :fully_associated do
      association :agent_invocation
      association :agent_issue
      association :agent_improvement
    end

    # Trait for recent changes
    trait :recent do
      created_at { 1.day.ago }
    end

    # Trait for old changes
    trait :old do
      created_at { 90.days.ago }
    end
  end
end
