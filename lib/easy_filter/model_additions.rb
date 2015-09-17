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

      filter = self
      params.each do |key, value|
        next unless key.start_with?(prefixes[:main]) && !value.blank? && key != "#{prefixes[:main]}button"
        filter = add_where(filter, del_prefix(key, prefixes[:main]), value, prefixes)
      end

      params[prefixes[:sort]] ||= 'id'
      params[prefixes[:direction]] ||= 'desc'

      # TODO: included model fields not in 'column_names'. Somehow need to check if given column name valid
      # sort_column = column_names.include?(params[prefixes[:sort]]) ? params[prefixes[:sort]] : add_model('id')
      filter.order("#{add_model params[prefixes[:sort]]} #{sort_direction(params)}")
    end

    private

    def sort_direction(params)
      %w(asc desc).include?(params[prefixes[:direction]]) ? params[prefixes[:direction]] : 'desc'
    end

    def add_where(filter, field, value, prefixes)
      if field.start_with?(prefixes[:from])
        filter.where("#{add_model(del_prefix(field, prefixes[:from]))} >= ?", value)

      elsif field.start_with?(prefixes[:to])
        filter.where("#{add_model(del_prefix(field, prefixes[:to]))} <= ?", value)

      elsif field.start_with?(prefixes[:exact])
        filter.where("#{add_model(del_prefix(field, prefixes[:exact]))} = ?", value)

      else
        filter.where("#{add_model(field)} like ?", "%#{value}%")
      end
    end

    def del_prefix(name, prefix)
      return name.gsub(prefix, '').to_s if name.start_with?(prefix)
      name
    end

    def add_model(field)
      return quoted_table_name + '.' + field unless field.include? '.'
      field
    end
  end
end
