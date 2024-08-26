module PowerSuppliesHelper

  def psu_filter_headers
    content_tag(:tr, nil,
      class: 'bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-600',
      data:  { controller: 'psu-filters-form' }
    ) do
      content_tag(:th, nil, scope: :row, class: 'text-xs px-5 py-3') do
        psu_select(:manufacturer)
      end +
        content_tag(:th, nil, colspan: 2) +
        content_tag(:th) do
          psu_select(:atx_version)
        end +
        content_tag(:th) do
          psu_select(:wattage)
        end +
        content_tag(:th, nil, colspan: 2) +
        content_tag(:th) do
          psu_select(:efficiency_rating)
        end +
        pagination_headers
    end
  end

  private

  def pagination_headers
    if user_signed_in?
      content_tag(:th, nil) +
        pagination_th +
        content_tag(:th, nil, colspan: 3)
    else
      content_tag(:th, nil) + pagination_th
    end
  end

  def pagination_th
    content_tag(:th, nil, class: 'text-right') do
      "Items per page <br/>#{pagination_select}".html_safe
    end
  end

  def psu_select(column)
    selected = @dropdown_filters[column] || 'All'
    select_tag("filters[#{column}]",
      options_for_select(@dropdowns[column], selected),
      {
        prompt: "All",
        form:   :psu_filters,
        class:  'text-xs',
        data:   { action: "change->psu-filters-form#submit" }
      }
    )
  end

  def pagination_select
    selected = @records_per_page || 'All'
    select_tag(:per_page,
      options_for_select([5, 10, 20, 50], selected),
      {
        form:  :psu_filters,
        class: 'text-xs',
        data:  { action: "change->psu-filters-form#submit" }
      }
    )
  end
end
