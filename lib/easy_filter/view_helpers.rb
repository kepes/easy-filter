module EasyFilter
  # View helpers for EasyFilter
  module ViewHelpers
    def easy_sort(column, title = nil)
      config = easy_filter_defaults
      cleaned_params = clean_params params, config
      title ||= column.titleize
      dir = sort_direction column, config

      render partial: 'easy_filter/sort_field',
             locals:
             { column: column.to_s,
               title: title,
               sort_param_name: config[:sort_params][:field],
               direction: dir,
               direction_param_name: config[:sort_params][:direction],
               cleaned_params: cleaned_params
             }
    end

    def easy_filter(model_class, filters)
      config = easy_filter_defaults
      cleaned_params = clean_params params, config
      form = render_easy 'form_open', config, cleaned_params

      filters.each do |filter|
        f = determine_column filter, model_class
        form += render_field f, config, cleaned_params
      end

      form += render_easy 'buttons', config, cleaned_params
      form += render_easy 'form_close', config, cleaned_params
    end

    private

    def easy_filter_defaults
      rails_defaults = Rails.configuration.easy_filter_defaults if defined? Rails.configuration.easy_filter_defaults
      rails_defaults ||= {}
      {
        prefixes: { main: 'filter_', from: 'from_', to: 'to_', exact: 'exact_' },
        allowed_params: %w(sort direction),
        sort_params: { field: 'sort', direction: 'direction' }
      }.deep_merge rails_defaults
    end

    def sort_direction(column, config)
      (column.to_s == params[config[:sort_params][:field]] && params[config[:sort_params][:direction]] == 'asc') ? 'desc' : 'asc'
    end

    def render_field(filter, config, cleaned_params)
      form = render_easy 'form_field_open', config, cleaned_params
      view = column_view filter[:col_type]
      form += render_easy view, config, cleaned_params, filter
      form + render_easy('form_field_close', config, cleaned_params)
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

    def render_easy(name, config, cleaned_params, filter = nil)
      render partial: "easy_filter/#{name}",
             locals: {
               filter_prefixes: config[:prefixes],
               filter: filter,
               cleaned_params: cleaned_params
             }
    end

    def clean_params(params, config)
      params.select { |k| k.to_s.starts_with?(config[:prefixes][:main]) || config[:allowed_params].include?(k) }
    end

    def boolean_array
      [{ value: 1, text: t(:yes), color: :success, icon: 'check' },
       { value: 0, text: t(:no), color: :danger, icon: 'remove' }]
    end
  end
end
