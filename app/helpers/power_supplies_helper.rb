module PowerSuppliesHelper
  def psu_select(form, column)
    selected = @dropdown_filters[column] || 'All'
    form.select(column,
      options_for_select(@dropdowns[column], selected),
      { prompt: "All" },
      { class: 'text-xs', data: { action: "change->psu#change" } }
    )
  end
end
