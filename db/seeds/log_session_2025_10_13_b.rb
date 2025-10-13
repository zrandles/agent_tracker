# Log agent invocations from 2025-10-13 session (second session)

# Get agents
feature_prioritizer = Agent.find_by(agent_number: 1)

invocations_data = [
  {
    agent: feature_prioritizer, # Placeholder for general-purpose agent
    task_description: "Analyzed Chromatic game UX and identified 15 issues across Critical/High/Medium priorities",
    invocation_mode: "subagent",
    context_notes: "chromatic - UX analysis (general-purpose subagent)",
    started_at: Time.parse("2025-10-13 22:00:00"),
    completed_at: Time.parse("2025-10-13 22:10:00"),
    duration_minutes: 10,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Comprehensive UX analysis: 4 critical issues (turn indicator, rules reference, 3-card cost, next plays), 5 high priority, 6 medium. Identified 'quick wins' that would immediately improve new player experience."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Implemented 3 quick win UX fixes for Chromatic game",
    invocation_mode: "subagent",
    context_notes: "chromatic - UX quick wins (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 22:10:00"),
    completed_at: Time.parse("2025-10-13 22:18:00"),
    duration_minutes: 8,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Added: 1) Turn indicator (YOUR TURN/AI THINKING), 2) Color rules reference panel visible during gameplay, 3) 3-card cost warnings in dropdown + helper text. Deployed to production."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Built complete Shopify Inventory Opportunity Cost Calculator MVP",
    invocation_mode: "subagent",
    context_notes: "shopify_stockout_calc - full app build (rails-expert subagent, ran in parallel with Chromatic)",
    started_at: Time.parse("2025-10-13 22:10:00"),
    completed_at: Time.parse("2025-10-13 22:28:00"),
    duration_minutes: 18,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Complete MVP: 5 models (User, Store, Product, InventorySnapshot, StockoutEvent, Alert), revenue loss calculation engine, dashboard with charts, background jobs (Solid Queue), Tailwind UI. Ready for Shopify OAuth integration."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Implemented 5 high-priority Chromatic UX improvements",
    invocation_mode: "subagent",
    context_notes: "chromatic - Phase 2 UX improvements (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 22:28:00"),
    completed_at: Time.parse("2025-10-13 22:38:00"),
    duration_minutes: 10,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Added: 1) Valid next plays hints on each path, 2) Scoring preview showing exponential growth, 3) Deck state display with color coding, 4) Yellow path completion indicator, 5) Round end summary with 'Continue' button. Deployed to production."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Fixed missing Tailwind CSS styling in production Chromatic deployment",
    invocation_mode: "subagent",
    context_notes: "chromatic - bug fix (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 22:38:00"),
    completed_at: Time.parse("2025-10-13 22:45:00"),
    duration_minutes: 7,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Fixed Capistrano deployment not compiling Tailwind CSS. Updated deploy.rb to run `rails tailwindcss:build` before assets:precompile. Manually compiled assets and restarted service. All styling now working in production."
  }
]

puts "Logging #{invocations_data.length} agent invocations..."

invocations_data.each_with_index do |data, i|
  invocation = AgentInvocation.create!(data)
  puts "✅ #{i+1}. Logged: #{invocation.task_description[0..60]}... (#{invocation.duration_minutes} min, #{invocation.invocation_mode})"
end

puts "\n✅ Successfully logged #{invocations_data.length} invocations"
puts "Total duration: #{invocations_data.sum { |d| d[:duration_minutes] }} minutes"
puts "View at: http://24.199.71.69/agent_tracker"
