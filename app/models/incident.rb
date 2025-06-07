class Incident < ApplicationRecord
  validates :title, presence: true
  validates :severity, inclusion: { in: %w[sev0 sev1 sev2 sev3], allow_blank: true }
  validates :status, inclusion: { in: %w[open resolved], message: "%{value} is not a valid status" }
end
