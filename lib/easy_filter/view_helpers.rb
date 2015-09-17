module EasyFilter
  # View helpers for EasyFilter
  module ViewHelpers
    def easy_sort(column, title = nil, sort = 'sort', direction = 'direction')
      title ||= column.titleize
      dir = (column.to_s == params[sort] && params[direction] == 'asc') ? 'desc' : 'asc'

      render partial: 'easy_filter/sort_field',
             locals: { column: column.to_s,
                       title: title,
                       sort_param_name: sort,
                       direction: dir,
                       direction_param_name: direction }
    end

    def easy_filter(model_class, filters, prefixes = { main: 'filter_', from: 'from_', to: 'to_', exact: 'exact_' })
      form = render_easy 'form_open', prefixes, model_class

      filters.each do |filter|
        f = determine_column filter, model_class
        form += render_easy 'form_field_open', prefixes

        case f[:col_type]
        when :datetime
          form += render_easy 'field_datetime', prefixes, f

        when :date
          form += render_easy 'field_datetime', prefixes, f

        when :array
          form += render_easy 'field_array', prefixes, f

        else
          form += render_easy 'field_text', prefixes, f
        end

        form += render_easy 'form_field_close', prefixes
      end

      form += render_easy 'buttons', prefixes
      form += render_easy 'form_close', prefixes
    end

    private

    def determine_column(filter, model_class)
      filter = { field: filter.to_s } if filter.is_a?(Symbol) || filter.is_a?(String)
      filter[:field] = filter[:field].to_s
      filter[:label] ||= t("activerecord.attributes.#{model_class.name.underscore}.#{filter[:field]}")

      if filter[:items].nil?
        model_class.columns.each do |column|
          if column.name == filter[:field]
            filter[:col_type] = column.type
            break
          end
        end
        if filter[:col_type] == :boolean
          filter[:items] = boolean_array
          filter[:col_type] = :array
        end
      else
        filter[:col_type] = :array
      end

      filter
    end

    def render_easy(name, prefixes, filter = nil)
      render partial: "easy_filter/#{name}",
             locals: { filter_prefixes: prefixes,
                       filter: filter }
    end

    def boolean_array
      [{ value: 1, text: t(:yes), color: :success, icon: 'check' },
       { value: 0, text: t(:no), color: :danger, icon: 'remove' }]
    end
  end
end
