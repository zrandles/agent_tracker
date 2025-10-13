# Clear existing data
AgentChange.destroy_all
AgentImprovement.destroy_all
AgentIssue.destroy_all
AgentInvocation.destroy_all
Agent.destroy_all

puts "Creating 100 agents..."

agents_data = [
  # Research Agents (1-15)
  { number: 1, name: "Market Research Specialist", category: "research", tier: 1 },
  { number: 2, name: "Competitive Intelligence", category: "research", tier: 2 },
  { number: 3, name: "Customer Interview Analyzer", category: "research", tier: 1 },
  { number: 4, name: "Patent Research", category: "research", tier: 3 },
  { number: 5, name: "Academic Literature Review", category: "research", tier: 2 },
  { number: 6, name: "Industry Trends Analyst", category: "research", tier: 1 },
  { number: 7, name: "Technical Documentation Research", category: "research", tier: 2 },
  { number: 8, name: "User Research Synthesizer", category: "research", tier: 1 },
  { number: 9, name: "Data Source Discovery", category: "research", tier: 2 },
  { number: 10, name: "Regulatory Research", category: "research", tier: 3 },
  { number: 11, name: "Technology Stack Research", category: "research", tier: 2 },
  { number: 12, name: "Best Practices Research", category: "research", tier: 1 },
  { number: 13, name: "Case Study Analyzer", category: "research", tier: 2 },
  { number: 14, name: "Historical Data Researcher", category: "research", tier: 2 },
  { number: 15, name: "Feasibility Researcher", category: "research", tier: 2 },

  # Planning Agents (16-25)
  { number: 16, name: "Project Planner", category: "planning", tier: 1 },
  { number: 17, name: "Sprint Planning Assistant", category: "planning", tier: 1 },
  { number: 18, name: "Resource Allocation Optimizer", category: "planning", tier: 3 },
  { number: 19, name: "Timeline Estimator", category: "planning", tier: 2 },
  { number: 20, name: "Risk Assessment", category: "planning", tier: 2 },
  { number: 21, name: "Architecture Planner", category: "planning", tier: 3 },
  { number: 22, name: "Dependency Mapper", category: "planning", tier: 2 },
  { number: 23, name: "Milestone Tracker", category: "planning", tier: 1 },
  { number: 24, name: "Capacity Planner", category: "planning", tier: 2 },
  { number: 25, name: "Technical Debt Prioritizer", category: "planning", tier: 2 },

  # Writing Agents (26-35)
  { number: 26, name: "Technical Writer", category: "writing", tier: 1 },
  { number: 27, name: "API Documentation Generator", category: "writing", tier: 2 },
  { number: 28, name: "User Guide Creator", category: "writing", tier: 1 },
  { number: 29, name: "Code Comment Generator", category: "writing", tier: 1 },
  { number: 30, name: "Changelog Compiler", category: "writing", tier: 1 },
  { number: 31, name: "README Generator", category: "writing", tier: 1 },
  { number: 32, name: "Blog Post Writer", category: "writing", tier: 2 },
  { number: 33, name: "Email Template Creator", category: "writing", tier: 1 },
  { number: 34, name: "Tutorial Writer", category: "writing", tier: 2 },
  { number: 35, name: "Migration Guide Writer", category: "writing", tier: 2 },

  # Coding Agents (36-50)
  { number: 36, name: "Rails Expert", category: "coding", tier: 1 },
  { number: 37, name: "Frontend Developer", category: "coding", tier: 2 },
  { number: 38, name: "API Builder", category: "coding", tier: 2 },
  { number: 39, name: "Database Schema Designer", category: "coding", tier: 2 },
  { number: 40, name: "Migration Generator", category: "coding", tier: 1 },
  { number: 41, name: "Model Builder", category: "coding", tier: 1 },
  { number: 42, name: "Controller Generator", category: "coding", tier: 1 },
  { number: 43, name: "View Builder", category: "coding", tier: 1 },
  { number: 44, name: "Background Job Creator", category: "coding", tier: 2 },
  { number: 45, name: "Form Builder", category: "coding", tier: 1 },
  { number: 46, name: "Validation Logic", category: "coding", tier: 1 },
  { number: 47, name: "Authentication Specialist", category: "coding", tier: 3 },
  { number: 48, name: "Authorization Logic", category: "coding", tier: 3 },
  { number: 49, name: "Payment Integration", category: "coding", tier: 3 },
  { number: 50, name: "Email Integration", category: "coding", tier: 2 },

  # Debugging Agents (51-60)
  { number: 51, name: "Error Analyzer", category: "debugging", tier: 2 },
  { number: 52, name: "Stack Trace Interpreter", category: "debugging", tier: 2 },
  { number: 53, name: "Log Analyzer", category: "debugging", tier: 2 },
  { number: 54, name: "Performance Profiler", category: "debugging", tier: 3 },
  { number: 55, name: "Memory Leak Detector", category: "debugging", tier: 3 },
  { number: 56, name: "SQL Query Optimizer", category: "debugging", tier: 3 },
  { number: 57, name: "N+1 Query Detective", category: "debugging", tier: 2 },
  { number: 58, name: "Race Condition Hunter", category: "debugging", tier: 4 },
  { number: 59, name: "Regression Finder", category: "debugging", tier: 2 },
  { number: 60, name: "Root Cause Analyzer", category: "debugging", tier: 3 },

  # Testing Agents (61-68)
  { number: 61, name: "Unit Test Generator", category: "testing", tier: 1 },
  { number: 62, name: "Integration Test Writer", category: "testing", tier: 2 },
  { number: 63, name: "System Test Creator", category: "testing", tier: 2 },
  { number: 64, name: "Test Coverage Analyzer", category: "testing", tier: 2 },
  { number: 65, name: "Fixture Generator", category: "testing", tier: 1 },
  { number: 66, name: "Mock/Stub Creator", category: "testing", tier: 2 },
  { number: 67, name: "Load Test Designer", category: "testing", tier: 3 },
  { number: 68, name: "Security Test Writer", category: "testing", tier: 3 },

  # Deployment Agents (69-75)
  { number: 69, name: "Deployment Specialist", category: "deployment", tier: 2 },
  { number: 70, name: "CI/CD Pipeline Builder", category: "deployment", tier: 3 },
  { number: 71, name: "Server Provisioner", category: "deployment", tier: 3 },
  { number: 72, name: "Container Orchestrator", category: "deployment", tier: 4 },
  { number: 73, name: "Rollback Manager", category: "deployment", tier: 2 },
  { number: 74, name: "Zero-Downtime Deployer", category: "deployment", tier: 3 },
  { number: 75, name: "Environment Manager", category: "deployment", tier: 2 },

  # Database Agents (76-80)
  { number: 76, name: "Database Administrator", category: "database", tier: 3 },
  { number: 77, name: "Migration Reviewer", category: "database", tier: 2 },
  { number: 78, name: "Index Optimizer", category: "database", tier: 3 },
  { number: 79, name: "Backup Manager", category: "database", tier: 3 },
  { number: 80, name: "Query Performance Tuner", category: "database", tier: 3 },

  # Monitoring Agents (81-85)
  { number: 81, name: "Application Monitor", category: "monitoring", tier: 2 },
  { number: 82, name: "Error Tracker", category: "monitoring", tier: 2 },
  { number: 83, name: "Performance Monitor", category: "monitoring", tier: 2 },
  { number: 84, name: "Uptime Monitor", category: "monitoring", tier: 2 },
  { number: 85, name: "Alert Manager", category: "monitoring", tier: 2 },

  # Security Agents (86-90)
  { number: 86, name: "Security Auditor", category: "security", tier: 3 },
  { number: 87, name: "Vulnerability Scanner", category: "security", tier: 3 },
  { number: 88, name: "Dependency Checker", category: "security", tier: 2 },
  { number: 89, name: "Penetration Tester", category: "security", tier: 4 },
  { number: 90, name: "Compliance Checker", category: "security", tier: 3 },

  # Optimization Agents (91-95)
  { number: 91, name: "Code Optimizer", category: "optimization", tier: 2 },
  { number: 92, name: "Asset Optimizer", category: "optimization", tier: 2 },
  { number: 93, name: "Cache Strategy Designer", category: "optimization", tier: 3 },
  { number: 94, name: "Bundle Size Reducer", category: "optimization", tier: 2 },
  { number: 95, name: "Database Query Optimizer", category: "optimization", tier: 3 },

  # Documentation Agents (96-100)
  { number: 96, name: "Architecture Documenter", category: "documentation", tier: 2 },
  { number: 97, name: "ADR Writer", category: "documentation", tier: 2 },
  { number: 98, name: "Onboarding Guide Creator", category: "documentation", tier: 2 },
  { number: 99, name: "Troubleshooting Guide Writer", category: "documentation", tier: 2 },
  { number: 100, name: "Knowledge Base Builder", category: "documentation", tier: 2 }
]

agents_data.each do |data|
  Agent.create!(
    agent_number: data[:number],
    name: data[:name],
    category: data[:category],
    tier: data[:tier],
    status: 'active'
  )
  print "."
end

puts "\n✓ Created #{Agent.count} agents"

# Create some sample invocations for demonstration
puts "\nCreating sample invocations..."

# Sample invocation for Rails Expert
rails_expert = Agent.find_by(agent_number: 36)
if rails_expert
  invocation = AgentInvocation.create!(
    agent: rails_expert,
    task_description: "Build complete agent_tracker Rails application",
    invocation_mode: "manual",
    started_at: 2.hours.ago,
    completed_at: 30.minutes.ago,
    success: true,
    satisfaction_rating: 5,
    outcome_notes: "Successfully created all models, controllers, views, and deployed to production",
    tokens_input: 50000,
    tokens_output: 25000,
    tokens_total: 75000
  )

  # Create a change record
  AgentChange.create!(
    agent: rails_expert,
    agent_invocation: invocation,
    change_type: "capability_added",
    change_description: "Built complete agent_tracker application with 5 models, dashboard, and CLI tool",
    triggered_by: "initial_creation"
  )
end

puts "✓ Created sample data"
puts "\nSeeding complete!"
puts "  - #{Agent.count} agents"
puts "  - #{AgentInvocation.count} invocations"
puts "  - #{AgentChange.count} changes"
