class AddSlackFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :slack_user_name, :string
    add_column :users, :slack_user_id, :string
  end
end
