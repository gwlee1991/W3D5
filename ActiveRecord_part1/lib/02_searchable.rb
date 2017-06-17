require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    values = params.values
    where_line = params.keys.map{|key|"#{key} = ?"}
    joint = where_line.join(' AND ')

    p joint
    p values
  end
end

class SQLObject
  include Searchable
end
