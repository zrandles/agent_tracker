# Log agent invocations from 2025-10-13 session

# Get agents (Feature Prioritizer is #1, others will need to be created or found)
feature_prioritizer = Agent.find_by(agent_number: 1)

# rails-expert and market-research aren't in the 100 agents list, so we'll note them in context
# For now, we'll use generic agents or create placeholder entries

invocations_data = [
  {
    agent: feature_prioritizer,
    task_description: "Prioritized features for agent_tracker application using RICE framework",
    invocation_mode: "manual",
    context_notes: "agents repository - building agent_tracker",
    started_at: Time.parse("2025-10-13 14:00:00"),
    completed_at: Time.parse("2025-10-13 14:15:00"),
    duration_minutes: 15,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Clear prioritization: agent_tracker #1 (RICE 180), Agent Search #2 (RICE 80). Identified tracking invocation mode (subagent vs manual) as critical feature. Designed complete schema with 5 models."
  },
  {
    agent: feature_prioritizer, # Using as placeholder for rails-expert
    task_description: "Created complete implementation plan for agent_tracker Rails application",
    invocation_mode: "subagent",
    context_notes: "agents repository - planning agent_tracker (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 14:15:00"),
    completed_at: Time.parse("2025-10-13 14:25:00"),
    duration_minutes: 10,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Comprehensive plan: 5 models (Agent, AgentInvocation, AgentIssue, AgentImprovement, AgentChange), seed data for 100 agents, controllers, views, CLI tool. Full implementation commands provided."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Built complete agent_tracker Rails application from scratch",
    invocation_mode: "subagent",
    context_notes: "agents repository (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 14:25:00"),
    completed_at: Time.parse("2025-10-13 15:10:00"),
    duration_minutes: 45,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Full app deployed to http://24.199.71.69/agent_tracker with 5 models, dashboard, quick log form, 100 agents seeded. Working end-to-end."
  },
  {
    agent: feature_prioritizer, # Placeholder for market-research
    task_description: "Researched Shopify Inventory Opportunity Cost SaaS idea with 90-min deep dive",
    invocation_mode: "subagent",
    context_notes: "idea_tracker - validating SaaS idea (market-research subagent)",
    started_at: Time.parse("2025-10-13 15:10:00"),
    completed_at: Time.parse("2025-10-13 16:40:00"),
    duration_minutes: 90,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "BUILD NOW (8/10 confidence). Market: $350B annual losses to stockouts, 4.8M Shopify stores, weak competition at $49-99 price point. Full report saved to docs/market_research/. Recommended: landing page test first."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Built Chromatic card game MVP with 5-color mechanic",
    invocation_mode: "subagent",
    context_notes: "idea_tracker - game development (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 15:10:00"),
    completed_at: Time.parse("2025-10-13 16:10:00"),
    duration_minutes: 60,
    success: true,
    satisfaction_rating: 4,
    outcome_notes: "Game built and deployed to http://24.199.71.69/chromatic with 5 color rules (Red: jumps, Blue: waves, Green: consecutive, Yellow: solo, Purple: exponential), scoring, AI opponent. Pure CSS, no images. Had 500 error on launch requiring fix."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Fixed Chromatic 500 error on game start button",
    invocation_mode: "subagent",
    context_notes: "chromatic - bug fix (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 20:54:00"),
    completed_at: Time.parse("2025-10-13 21:09:00"),
    duration_minutes: 15,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Bug fixed: game_state initialization order issue - draw_hand called before deck initialized. Fixed by restructuring setup_new_game method. Deployed and verified working."
  },
  {
    agent: feature_prioritizer, # Placeholder for rails-expert
    task_description: "Built Shopify Inventory Opportunity Cost landing page with free calculator",
    invocation_mode: "subagent",
    context_notes: "shopify_stockout_calc - demand validation (rails-expert subagent)",
    started_at: Time.parse("2025-10-13 20:54:00"),
    completed_at: Time.parse("2025-10-13 21:39:00"),
    duration_minutes: 45,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Landing page live at http://24.199.71.69/shopify_stockout_calc/ with free revenue loss calculator and email signup. Clean Tailwind design. Ready to validate demand (target: 50+ signups before building full app)."
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
