# Cleanup unused agents - 97 agents with 0 invocations
# Only keeps agents that have been used at least once

# Get unused agents (0 invocations)
unused_agents = Agent.left_joins(:agent_invocations)
                    .where(agent_invocations: { id: nil })
                    .order(:agent_number)

puts "Found #{unused_agents.count} unused agents"
puts "\nAgents to DELETE (0 invocations):"
unused_agents.each do |agent|
  puts "  #{agent.agent_number}. #{agent.name}"
end

puts "\n" + "="*80
puts "KEEPING these agents (have invocations):"
Agent.joins(:agent_invocations)
     .select('agents.*, COUNT(agent_invocations.id) as inv_count')
     .group('agents.id')
     .order('inv_count DESC')
     .each do |agent|
  inv_count = agent.agent_invocations.count
  puts "  #{agent.agent_number}. #{agent.name} (#{inv_count} invocations)"
end

puts "\n" + "="*80
print "\nProceed with deletion? (yes/no): "
response = STDIN.gets.chomp.downcase

if response == 'yes'
  count = 0
  unused_agents.find_each do |agent|
    agent.destroy!
    count += 1
    print "\rDeleted #{count}/#{unused_agents.count} agents..."
  end
  puts "\n✅ Cleanup complete! Deleted #{count} unused agents."
  puts "Remaining agents: #{Agent.count}"
else
  puts "❌ Cleanup cancelled."
end
