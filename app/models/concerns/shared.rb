module Shared extend ActiveSupport::Concern
  def url_slug(id, name)
  	name = name || ''
    "#{id}-#{UnicodeUtils::nfkd('-'+ name + '-').downcase.gsub(/[^[:alnum:]]/,'-')}".gsub(/-{2,}/,'-').gsub(/-$/,'')
  end   

  def self.increment_read!(ids, table_name, attr_name, connection)
    if ids.is_a?(Array)
      query_ids = ids.map(&:to_i).join(',')
    else
      query_ids = ids.to_i
    end
    the_fields = [table_name, attr_name, attr_name, query_ids]
    the_sql = "UPDATE %s SET %s = %s + 1 WHERE id IN (%s)" % the_fields
    connection.execute(the_sql)
  end

end
