class AddIndexToIncidentsSlackUserId < ActiveRecord::Migration[7.2]
  def change
    add_index :incidents, :slack_user_id
  end
end
