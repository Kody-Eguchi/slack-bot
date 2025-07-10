class User < ApplicationRecord
  has_many :incidents, primary_key: "slack_user_id", foreign_key: "slack_user_id"
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
