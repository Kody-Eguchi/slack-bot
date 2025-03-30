module SlackHelper
  def handle_params(parts)
    # Identify severity
    valid_severities = ['sev0', 'sev1', 'sev2']
    severity = valid_severities.include?(parts.last) ? parts.pop : 'sev1' 

    # Extract title and description 
    title = parts.shift 
    description = parts.join(" ") || nil

    [title, description, severity]
  end

end
