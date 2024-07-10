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
