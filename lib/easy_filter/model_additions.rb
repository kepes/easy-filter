module EasyFilter
  # Define methods for ActiveRecord
  module ModelAdditions
    # 'easy_filter' for ActiveRecor models to filter result based on a filter hash
    # or HTTP parameters.
    #
    # @params [Hash] filter parameters hash
    # @prefixes [Hash] filter parameter prefixes mainly for prefixing HTML input elements
    def easy_filter(params, prefixes = { main: 'filter_',
                                         from: 'from_',
                                         to: 'to_',
                                         exact: 'exact_',
                                         sort: 'sort',
                                         direction: 'direction' })
      params = assign_defaults params, prefixes
      create_filter params, prefixes
    end

    private

    def assign_defaults(params, prefixes)
      params[prefixes[:sort]] ||= 'id'
      params[prefixes[:direction]] ||= 'desc'
      params
    end

    def create_filter(params, prefixes)
      filter = self
      params.each do |key, value|
        if key.start_with?(prefixes[:main]) && !value.blank? && key != "#{prefixes[:main]}button"
          filter = add_where(filter, key, value, prefixes)
        end
      end

      # TODO: included model fields not in 'column_names'. Somehow need to check if given column name valid
      # sort_column = column_names.include?(params[prefixes[:sort]]) ? params[prefixes[:sort]] : add_model('id')
      filter.order("#{add_model params[prefixes[:sort]]} #{sort_direction(params, prefixes)}")
    end

    def sort_direction(params, prefixes)
      %w(asc desc).include?(params[prefixes[:direction]]) ? params[prefixes[:direction]] : 'desc'
    end

    def add_where(filter, field, value, prefixes)
      f = prefixed? field, prefixes[:main]
      return filter unless f

      f, op = get_operator f, prefixes
      f = add_model f

      if op.blank?
        condition = "#{f} like ?"
        value = "%#{value}%"
      else
        condition = "#{f} #{op}"
      end

      filter.where(condition, value)
    end

    def prefixed?(text, prefix)
      return false unless text.start_with? prefix
      text.sub(prefix, '')
    end

    def get_operator(field, prefixes)
      operators = {
        prefixes[:from] => '>= ?',
        prefixes[:to] => '<= ?',
        prefixes[:exact] => '= ?'
      }

      operators.each do |k, v|
        f = prefixed? field, k
        return f, v if f
      end

      [field, nil]
    end

    def add_model(field)
      return quoted_table_name + '.' + field unless field.include? '.'
      field
    end
  end
end
