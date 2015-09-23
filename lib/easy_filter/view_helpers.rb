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
        form += render_field f, prefixes
      end

      form += render_easy 'buttons', prefixes
      form += render_easy 'form_close', prefixes
    end

    private

    def render_field(filter, prefixes)
      form = render_easy 'form_field_open', prefixes
      view = column_view filter[:col_type]
      form += render_easy view, prefixes, filter
      form + render_easy('form_field_close', prefixes)
    end

    def column_view(col_type)
      views = {
        datetime: 'field_datetime',
        date:     'field_datetime',
        array:    'field_array'
      }
      view = views[col_type]
      view ||= 'field_text'
      view
    end

    def determine_column(filter, model_class)
      filter = check_filter_values filter, model_class

      if filter[:items].nil?
        filter[:col_type] = column_type_from_model model_class, filter[:field]
        filter = check_boolean filter
      else
        filter[:col_type] = :array
      end

      filter
    end

    def check_boolean(filter)
      if filter[:col_type] == :boolean
        filter[:items] = boolean_array
        filter[:col_type] = :array
      end
      filter
    end

    def column_type_from_model(model_class, field)
      model_class.columns.each { |column| return column.type if column.name == field }
      nil
    end

    def check_filter_values(filter, model_class)
      filter = { field: filter.to_s } if filter.is_a?(Symbol) || filter.is_a?(String)
      filter[:field] = filter[:field].to_s
      filter[:label] ||= t("activerecord.attributes.#{model_class.name.underscore}.#{filter[:field]}")
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
