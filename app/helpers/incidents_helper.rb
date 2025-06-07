module IncidentsHelper
  def status_css_class(status)
    case status
    when 'open' then 'text-red-600'
    when 'resolved' then 'text-green-600'
    else 'text-gray-600'
    end
  end

  def sort_option(label, sort_field, direction)
    selected = (params[:sort]== sort_field && params[:direction] == direction) ? 'selected' : ''
    value = incidents_path(sort: sort_field, direction: direction)
    "<option value='#{value}' #{selected}>#{label}</option>".html_safe
  end
end
