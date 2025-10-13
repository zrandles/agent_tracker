class CreateAgentIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_issues do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :agent_invocation, null: true, foreign_key: true
      t.text :issue_description, null: false
      t.integer :severity, null: false
      t.string :status, null: false, default: 'open'
      t.text :resolution_notes

      t.timestamps
    end

    add_index :agent_issues, :severity
    add_index :agent_issues, :status
    add_index :agent_issues, [:agent_id, :status]
  end
end
