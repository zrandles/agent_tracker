FactoryBot.define do
  factory :agent_invocation do
    association :agent
    sequence(:task_description) { |n| "Task #{n}: Implement feature X" }
    invocation_mode { 'subagent' }
    context_notes { 'Working on feature development' }
    started_at { 2.hours.ago }
    completed_at { 1.hour.ago }
    success { true }
    satisfaction_rating { rand(3..5) }
    outcome_notes { 'Successfully completed the task' }
    tokens_input { rand(1000..5000) }
    tokens_output { rand(500..3000) }
    tokens_total { tokens_input + tokens_output }

    # Trait for different invocation modes
    trait :subagent do
      invocation_mode { 'subagent' }
    end

    trait :manual do
      invocation_mode { 'manual' }
    end

    # Trait for success states
    trait :successful do
      success { true }
      completed_at { 1.hour.ago }
      satisfaction_rating { 5 }
      outcome_notes { 'Task completed successfully' }
    end

    trait :failed do
      success { false }
      completed_at { 1.hour.ago }
      satisfaction_rating { 1 }
      outcome_notes { 'Task failed due to errors' }
    end

    trait :unknown_outcome do
      success { nil }
      completed_at { nil }
      satisfaction_rating { nil }
      outcome_notes { nil }
    end

    # Trait for in-progress invocations
    trait :in_progress do
      completed_at { nil }
      duration_minutes { nil }
      success { nil }
      satisfaction_rating { nil }
      outcome_notes { nil }
    end

    # Trait for completed invocations
    trait :completed do
      completed_at { 1.hour.ago }
      success { true }
    end

    # Trait for different satisfaction ratings
    trait :highly_satisfied do
      satisfaction_rating { 5 }
    end

    trait :unsatisfied do
      satisfaction_rating { 1 }
    end

    # Trait for token usage patterns
    trait :high_token_usage do
      tokens_input { rand(10000..20000) }
      tokens_output { rand(5000..10000) }
      tokens_total { tokens_input + tokens_output }
    end

    trait :low_token_usage do
      tokens_input { rand(100..500) }
      tokens_output { rand(50..200) }
      tokens_total { tokens_input + tokens_output }
    end

    trait :no_token_data do
      tokens_input { nil }
      tokens_output { nil }
      tokens_total { nil }
    end

    # Trait for long-running tasks
    trait :long_duration do
      started_at { 5.hours.ago }
      completed_at { 1.hour.ago }
    end

    trait :short_duration do
      started_at { 30.minutes.ago }
      completed_at { 10.minutes.ago }
    end

    # Trait with associated issues
    trait :with_issues do
      after(:create) do |invocation|
        create_list(:agent_issue, 2, agent_invocation: invocation, agent: invocation.agent)
      end
    end

    # Trait with associated changes
    trait :with_changes do
      after(:create) do |invocation|
        create_list(:agent_change, 3, agent_invocation: invocation, agent: invocation.agent)
      end
    end
  end
end
