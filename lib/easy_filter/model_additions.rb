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

        field = del_prefix(key, prefixes[:main])
        filter = add_where(filter, field, value, prefixes)
      end

      params[prefixes[:sort]] ||= 'id'
      params[prefixes[:direction]] ||= 'desc'

      sort_column = column_names.include?(params[prefixes[:sort]]) ? params[prefixes[:sort]] : 'id'
      sort_direction = %w(asc desc).include?(params[prefixes[:direction]]) ? params[prefixes[:direction]] : 'desc'

      filter.order("#{sort_column} #{sort_direction}")
    end

    private

    def add_where(filter, field, value, prefixes)
      if field.start_with?(prefixes[:from])
        filter.where("#{del_prefix(field, prefixes[:from])} >= ?", value)

      elsif field.start_with?(prefixes[:to])
        filter.where("#{del_prefix(field, prefixes[:to])} <= ?", value)

      elsif field.start_with?(prefixes[:exact])
        filter.where("#{del_prefix(field, prefixes[:exact])} = ?", value)

      else
        filter.where("#{field} like ?", "%#{value}%")
      end
    end

    def del_prefix(name, prefix)
      return name.gsub(prefix, '').to_s if name.start_with?(prefix)
      name
    end
  end
end
