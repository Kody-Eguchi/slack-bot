module IncidentsHelper
  def status_css_class(status)
    case status
    when 'open' then 'text-red-600'
    when 'resolved' then 'text-green-600'
    else 'text-gray-600'
    end
  end

  def toggle_incidents_button_label_and_path
    if params[:show_all] == "true"
      ["Show My Incidents", incidents_path(sort: params[:sort], direction: params[:direction])]
    else
      ["Show All", incidents_path(sort: params[:sort], direction: params[:direction], show_all: "true")]
    end
  end

  def sort_option(label, sort_field, direction)
    selected = (params[:sort]== sort_field && params[:direction] == direction) ? 'selected' : ''
    value = incidents_path(sort: sort_field, direction: direction)
    "<option value='#{value}' #{selected}>#{label}</option>".html_safe
  end
end
