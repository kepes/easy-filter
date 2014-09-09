module EasyFilter
  # Define methods for ActiveRecord
  module ModelAdditions
    def easy_filter(params, prefixes = { main: 'filter_',
                                         from: 'from_',
                                         to: 'to_',
                                         exact: 'exact_',
                                         sort: 'sort',
                                         direction: 'direction' })
      filter = self
      params.each do |key, value|
        next unless key.start_with?(prefixes[:main]) && !value.blank? && key != "#{prefixes[:main]}button"

        field = key.gsub(prefixes[:main], '').to_s
        if field.start_with?(prefixes[:from])
          filter = filter.where("#{field.gsub(prefixes[:from], '')} >= ?", value)
        elsif field.start_with?(prefixes[:to])
          filter = filter.where("#{field.gsub(prefixes[:to], '')} <= ?", value)
        elsif field.start_with?(prefixes[:exact])
          filter = filter.where("#{field.gsub(prefixes[:exact], '')} = ?", value)
        else
          filter = filter.where("#{field} like ?", "%#{value}%")
        end
      end
      params[prefixes[:sort]] ||= 'id'
      params[prefixes[:direction]] ||= 'desc'

      sort_column = column_names.include?(params[prefixes[:sort]]) ? params[prefixes[:sort]] : 'id'
      sort_direction = %w(asc desc).include?(params[prefixes[:direction]]) ? params[prefixes[:direction]] : 'desc'

      filter.order("#{sort_column} #{sort_direction}")
    end
  end
end
