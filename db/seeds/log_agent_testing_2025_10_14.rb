# Agent testing session - evaluating unused agents with real tasks
# October 14, 2025

feature_prioritizer = Agent.find_by(agent_number: 1) # Using market research as proxy since we don't have separate records
rails_expert = Agent.find_by(agent_number: 36)

invocations_data = [
  {
    agent: feature_prioritizer,
    task_description: "Prioritize 10 post-MVP features for Shopify Stockout Calculator using RICE framework",
    invocation_mode: "subagent",
    context_notes: "shopify_stockout_calc - Feature prioritization to decide what to build after MVP launch",
    started_at: Time.parse("2025-10-14 16:00:00"),
    completed_at: Time.parse("2025-10-14 16:18:00"),
    duration_minutes: 18,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "EXCEPTIONAL (5/5): Comprehensive RICE analysis with reach/impact/confidence/effort scores for all 10 features. Clear BUILD NOW recommendations (Email Digest, Custom Alerts, Trend Charts) with detailed rationale. Identified opportunity costs, strategic alignment, success metrics, and kill criteria. Output was immediately actionable with zero edits needed. Deliverable included implementation timeline, task breakdown, and decision framework for future features. This is exactly what feature prioritization should look like - would use again without hesitation."
  },
  {
    agent: rails_expert,
    task_description: "Security audit of Shopify OAuth implementation before production deployment",
    invocation_mode: "subagent",
    context_notes: "shopify_stockout_calc - Pre-production security review of OAuth flow, webhooks, token storage",
    started_at: Time.parse("2025-10-14 16:20:00"),
    completed_at: Time.parse("2025-10-14 16:45:00"),
    duration_minutes: 25,
    success: true,
    satisfaction_rating: 4,
    outcome_notes: "GOOD (4/5): Thorough security audit identifying 4 HIGH, 3 MEDIUM, and 4 LOW severity issues with specific fixes. Found critical production config issues (missing relative_url_root, host authorization, callback URLs) that would have caused complete failure. Excellent categorization by severity and clear production readiness checklist. However, some recommendations were overly cautious (rack-attack for webhooks from Shopify is rarely needed) and estimated fix time (11-15 hours) felt inflated for straightforward config changes. Would have been 5/5 if more pragmatic about low-risk issues. Still extremely valuable - caught deployment blockers I would have missed."
  }
]

invocations_data.each_with_index do |data, i|
  invocation = AgentInvocation.create!(data)
  puts "✅ #{i+1}. Logged: #{invocation.task_description[0..60]}... (Rating: #{invocation.satisfaction_rating}/5)"
end

puts "\n📊 Agent Testing Summary:"
puts "Total agents tested: 2"
puts "Rating 5/5: 1 (Feature Prioritizer)"
puts "Rating 4/5: 1 (Rails Expert)"
puts "Average rating: 4.5/5"
