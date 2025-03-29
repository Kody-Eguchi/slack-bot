class CreateIncidents < ActiveRecord::Migration[7.2]
  def change
    create_table :incidents do |t|
      t.string :title, null: false
      t.text :description
      t.string :severity
      t.string :status, default: 'open'
      t.string :creator
      t.string :slack_channel_id
      t.datetime :resolved_at
      
      t.timestamps
    end
  end
end
