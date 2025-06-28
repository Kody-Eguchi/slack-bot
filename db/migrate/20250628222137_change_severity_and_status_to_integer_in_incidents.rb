class ChangeSeverityAndStatusToIntegerInIncidents < ActiveRecord::Migration[7.2]
  def up
    # Add new integer columns with default
    add_column :incidents, :new_severity, :integer, default: 0, null: false
    add_column :incidents, :new_status, :integer, default: 0, null: false

    # Migrate data from old string columns to new integer columns
    execute <<-SQL
      UPDATE incidents SET new_severity =
        CASE severity
          WHEN 'sev0' THEN 0
          WHEN 'sev1' THEN 1
          WHEN 'sev2' THEN 2
          ELSE 0
        END
    SQL

    execute <<-SQL
      UPDATE incidents SET new_status =
        CASE status
          WHEN 'open' THEN 0
          WHEN 'resolved' THEN 1
          ELSE 0
        END
    SQL

    # Remove old columns
    remove_column :incidents, :severity
    remove_column :incidents, :status

    # Rename new columns
    rename_column :incidents, :new_severity, :severity
    rename_column :incidents, :new_status, :status
  end

  def down
    # Add string columns back
    add_column :incidents, :old_severity, :string, default: "sev0", null: false
    add_column :incidents, :old_status, :string, default: "open", null: false

    # Map integer values back to strings
    execute <<-SQL
      UPDATE incidents SET old_severity =
        CASE severity
          WHEN 0 THEN 'sev0'
          WHEN 1 THEN 'sev1'
          WHEN 2 THEN 'sev2'
          ELSE 'sev0'
        END
    SQL

    execute <<-SQL
      UPDATE incidents SET old_status =
        CASE status
          WHEN 0 THEN 'open'
          WHEN 1 THEN 'resolved'
          ELSE 'open'
        END
    SQL

    # Remove integer columns
    remove_column :incidents, :severity
    remove_column :incidents, :status

    # Rename old columns back
    rename_column :incidents, :old_severity, :severity
    rename_column :incidents, :old_status, :status
  end
end
