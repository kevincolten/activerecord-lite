require_relative './db_connection'

module Searchable
  def where(params)
    keys = params.keys.map { |key| "#{key} = ?"}
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{keys.join("AND ")}
    SQL
    DBConnection.execute(query, *params.values)
  end
end