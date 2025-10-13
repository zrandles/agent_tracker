class CreateAgentImprovements < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_improvements do |t|
      t.references :agent, null: false, foreign_key: true
      t.text :improvement_description, null: false
      t.integer :priority, null: false
      t.string :status, null: false, default: 'proposed'
      t.datetime :implemented_at

      t.timestamps
    end

    add_index :agent_improvements, :priority
    add_index :agent_improvements, :status
    add_index :agent_improvements, [:agent_id, :status]
  end
end
