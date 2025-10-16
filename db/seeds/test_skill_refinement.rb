# Test seed file to verify production-data-sync Skill refinements
# Purpose: Confirm rbenv paths work correctly in all commands

puts "Testing production-data-sync Skill..."
puts "Current database: #{ActiveRecord::Base.connection_db_config.database}"
puts "Current invocation count: #{AgentInvocation.count}"
puts "✅ Skill test successful - all rbenv paths working!"
