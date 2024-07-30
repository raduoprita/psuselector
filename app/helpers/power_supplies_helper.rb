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
        content_tag(:th, nil, colspan: 5)
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
end
