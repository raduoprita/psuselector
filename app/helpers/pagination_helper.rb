module PaginationHelper

  def pagination_button(direction)
    if direction == :prev
      page = @page <= 2 ? 1 : @page - 1
    else
      last_page = @pag_count / @limit <= 1
      page      = last_page ? @page : @page + 1
    end

    button_to(
      power_supplies_path,
      method: :get,
      params: { page: page },
      class:  'flex items-center justify-center px-3 h-8 text-sm font-medium text-white bg-gray-800 rounded-s hover:bg-gray-900 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white'
    ) do
      svg_arrow_tag direction
    end
  end

  private

  def svg_arrow_tag(direction)
    if direction == :prev
      text   = 'Prev'
      path_d = 'M13 5H1m0 0 4 4M1 5l4-4'
      tag1   = svg_tag(path_d)
      tag2   = text_tag(text)
    else
      text   = 'Next'
      path_d = 'M1 5h12m0 0L9 1m4 4L9 9'
      tag1   = text_tag(text)
      tag2   = svg_tag(path_d)
    end

    tag1 + tag2
  end

  def svg_tag(path_d)
    content_tag(
      :svg,
      nil,
      class:       'w-3.5 h-3.5 me-2 rtl:rotate-180',
      aria_hidden: true,
      xmlns:       'http://www.w3.org/2000/svg',
      fill:        :none,
      viewBox:     '0 0 14 10'
    ) do
      content_tag(
        :path,
        nil,
        stroke:          'currentColor',
        stroke_linecap:  'round',
        stroke_linejoin: 'round',
        stroke_width:    2,
        d:               path_d,
      )
    end
  end

  def text_tag(text)
    content_tag(:span, text, class: 'pr-2')
  end
end
