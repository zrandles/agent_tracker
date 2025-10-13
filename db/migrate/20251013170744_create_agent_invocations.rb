class CreateAgentInvocations < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_invocations do |t|
      t.references :agent, null: false, foreign_key: true
      t.text :task_description, null: false
      t.string :invocation_mode, null: false
      t.text :context_notes
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :duration_minutes
      t.boolean :success
      t.integer :satisfaction_rating
      t.text :outcome_notes
      t.integer :tokens_input
      t.integer :tokens_output
      t.integer :tokens_total

      t.timestamps
    end

    add_index :agent_invocations, :started_at
    add_index :agent_invocations, :invocation_mode
    add_index :agent_invocations, :success
    add_index :agent_invocations, [:agent_id, :started_at]
  end
end
