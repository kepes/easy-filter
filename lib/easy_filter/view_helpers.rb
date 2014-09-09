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
        col_name, col_type = determine_column filter, model_class
        form += render_easy 'form_field_open', prefixes, model_class

        case col_type
        when :datetime
          form += render_easy 'field_datetime', prefixes, model_class, col_name

        when :array
          form += render_easy 'field_array', prefixes, model_class, col_name, filter[1]

        else
          form += render_easy 'field_text', prefixes, model_class, col_name
        end

        form += render_easy 'form_field_close', prefixes, model_class
      end

      form += render_easy 'buttons', prefixes, model_class
      form += render_easy 'form_close', prefixes, model_class
    end

    private

    def determine_column(filter, model_class)
      col_name = filter if filter.is_a?(Symbol) || filter.is_a?(String)
      col_name = filter[0] if filter.is_a? Array

      col_type = nil
      if filter.is_a? Array
        col_type = :array
      else
        model_class.columns.each do |column|
          if column.name == col_name.to_s
            col_type = column.type
            break
          end
        end
      end
      [col_name, col_type]
    end

    def render_easy(name, prefixes, model_class, col_name = nil, elements = nil)
      render partial: "easy_filter/#{name}",
             locals: { filter_prefixes: prefixes,
                       filter_model_class: model_class,
                       filter_col_name: col_name,
                       elements: elements }
    end
  end
end
