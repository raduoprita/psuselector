module ApplicationHelper
  def sortable_table_header(title, column, path_method, **kwargs)
    content_tag(:th, kwargs) do
      sortable_column(title, column, path_method)
    end
  end

  def sortable_column(title, column, path_method, **)
    direction = (column.to_s == params[:sort].to_s && params[:direction] == "asc") ? "desc" : "asc"

    query_params = request.query_parameters.merge(sort: column, direction: direction)

    path = send(path_method, query_params)
    link_to(path, data: { turbo_action: "advance" }, class: "flex", **) do
      concat title
      concat sort_icon(column)
    end
  end

  def psu_select(form, column)
    selected = (@dropdown_filters)[column] || 'All'
    form.select(column,
      options_for_select(@dropdowns[column], selected),
      { prompt: "All" },
      { class: 'text-xs', data: { action: "change->psu#change" } }
    )
  end

  def edit_button_to(path_or_object)
    button_to "Edit", path_or_object,
      method: :get, data: { turbo_frame: "_top" },
      class:  'text-xs text-white bg-green-700 hover:bg-green-800 focus:outline-none focus:ring-4 focus:ring-green-300 font-small rounded-lg px-1 py-1 text-center dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-900'
  end

  def delete_button_to(path_or_object)
    button_to "Del", path_or_object,
      method: :delete, data: { turbo_confirm: "Are you sure?" },
      class:  'text-xs text-white bg-red-700 hover:bg-red-800 focus:outline-none focus:ring-4 focus:ring-red-300 font-small rounded-lg px-1 py-1 text-center dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900'
  end

  private

  def sort_icon(column)
    return
    return unless params[:sort].to_s == column.to_s

    if params[:direction] == "asc"
      svg_icon("M5 15l7-7 7 7")
    else
      svg_icon("M19 9l-7 7-7-7")
    end
  end

  def svg_icon(path_d)
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "ml-1 inline w-4 h-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
      "<path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='#{path_d}'></path>".html_safe
    end
  end
end
