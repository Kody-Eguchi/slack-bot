module IncidentsHelper
  def status_css_class(status)
    case status
    when 'open' then 'text-red-600'
    when 'resolved' then 'text-green-600'
    else 'text-gray-600'
    end
  end
end
