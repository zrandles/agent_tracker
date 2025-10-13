class CreateAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :agents do |t|
      t.integer :agent_number, null: false
      t.string :name, null: false
      t.string :category, null: false
      t.integer :tier, null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :agents, :agent_number, unique: true
    add_index :agents, :category
    add_index :agents, :tier
    add_index :agents, :status
  end
end
