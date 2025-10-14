# Test invocation - verifying agent tracking system works end-to-end
# October 14, 2025

market_research = Agent.find_by(agent_number: 1)

invocation_data = {
  agent: market_research,
  task_description: "Analyze Chromatic game for 3 specific marketing channels to reach first 100 players",
  invocation_mode: "subagent",
  context_notes: "chromatic - Low-risk test of agent tracking system, actionable marketing plan",
  started_at: Time.parse("2025-10-14 15:20:00"),
  completed_at: Time.parse("2025-10-14 15:40:00"),
  duration_minutes: 20,
  success: true,
  satisfaction_rating: 5,
  outcome_notes: "DELIVERED: 3 marketing channels (r/WebGames, itch.io, r/IndieGaming) with copy-paste templates, timing recommendations, and expected reach (80-350 players Week 1). Ready to execute immediately."
}

invocation = AgentInvocation.create!(invocation_data)
puts "✅ Logged test invocation: #{invocation.task_description[0..60]}..."
puts "📊 Total invocations now: #{AgentInvocation.count}"
