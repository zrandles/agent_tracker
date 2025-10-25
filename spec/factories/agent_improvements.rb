FactoryBot.define do
  factory :agent_improvement do
    association :agent
    sequence(:improvement_description) { |n| "Improvement #{n}: Enhance agent capabilities" }
    priority { rand(1..5) }
    status { 'proposed' }
    implemented_at { nil }

    # Trait for different statuses
    trait :proposed do
      status { 'proposed' }
      implemented_at { nil }
    end

    trait :approved do
      status { 'approved' }
      implemented_at { nil }
    end

    trait :implemented do
      status { 'implemented' }
      implemented_at { 1.week.ago }
    end

    trait :rejected do
      status { 'rejected' }
      implemented_at { nil }
    end

    # Trait for different priority levels
    trait :very_low do
      priority { 1 }
    end

    trait :low do
      priority { 2 }
    end

    trait :medium do
      priority { 3 }
    end

    trait :high do
      priority { 4 }
    end

    trait :critical do
      priority { 5 }
    end

    # Trait for high priority improvements
    trait :high_priority do
      priority { [4, 5].sample }
    end

    # Trait for low priority improvements
    trait :low_priority do
      priority { [1, 2].sample }
    end

    # Trait for pending improvements
    trait :pending do
      status { ['proposed', 'approved'].sample }
      implemented_at { nil }
    end

    # Trait with associated changes
    trait :with_changes do
      after(:create) do |improvement|
        create_list(:agent_change, 2, agent_improvement: improvement, agent: improvement.agent)
      end
    end

    # Trait for recently created improvements
    trait :recent do
      created_at { 1.day.ago }
    end

    # Trait for old improvements
    trait :old do
      created_at { 60.days.ago }
    end

    # Trait for recently implemented improvements
    trait :recently_implemented do
      status { 'implemented' }
      implemented_at { 2.days.ago }
    end
  end
end
