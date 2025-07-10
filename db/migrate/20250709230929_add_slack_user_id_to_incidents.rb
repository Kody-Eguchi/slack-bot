class AddSlackUserIdToIncidents < ActiveRecord::Migration[7.2]
  def change
    add_column :incidents, :slack_user_id, :string
  end
end
