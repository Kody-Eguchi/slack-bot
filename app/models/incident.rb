class Incident < ApplicationRecord
  belongs_to :user, primary_key: "slack_user_id", foreign_key: "slack_user_id", optional: true

  enum severity: { sev0: 0, sev1: 1, sev2: 2, sev3: 3 }, _prefix: true
  enum status: { open: 0, resolved: 1 }, _prefix: true

  validates :title, presence: true
  validate :severity_must_be_valid
  validate :status_must_be_valid

  def severity=(value)
    if self.class.severities.key?(value)
      super(value)
    else
      @invalid_severity = value
      super(nil)
    end
  end

  def status=(value)
    if self.class.statuses.key?(value)
      super(value)
    else
      @invalid_status = value
      super(nil)
    end
  end

  def severity_must_be_valid
    if @invalid_severity.present?
      errors.add(:severity, "is invalid")
    end
  end

  def status_must_be_valid
    if @invalid_status.present?
      errors.add(:status, "is invalid")
    end
  end
end

