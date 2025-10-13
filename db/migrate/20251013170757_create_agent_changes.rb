class CreateAgentChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_changes do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :change_type, null: false
      t.text :change_description, null: false
      t.text :before_value
      t.text :after_value
      t.string :triggered_by, null: false
      t.references :agent_invocation, null: true, foreign_key: true
      t.references :agent_issue, null: true, foreign_key: true
      t.references :agent_improvement, null: true, foreign_key: true

      t.timestamps
    end

    add_index :agent_changes, :change_type
    add_index :agent_changes, :triggered_by
    add_index :agent_changes, [:agent_id, :created_at]
  end
end
