require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'


class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.underscore
  end

  def self.all
    results = DBConnection.execute("SELECT * FROM #{self.table_name}")
    all_objects = []
    results.each do |result|
      all_objects << self.new(result)
    end
    all_objects
  end

  def self.find(id)
    arrays = DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = ?", id)
    all_objects = []
    arrays.each do |hash|
      all_objects << self.new(hash)
    end
    all_objects.first
  end

  def save
    (@id.nil?) ? create : update
  end

  private

  def create
    query = <<-SQL
    INSERT INTO #{self.class.table_name} ('#{self.class.attributes.join("', '")}')
    VALUES (#{(["?"] * self.class.attributes.length).join(", ")})
    SQL
    result = DBConnection.execute(query, *attribute_values)
    @id = DBConnection.last_insert_row_id
  end

  def update
    query = <<-SQL
    UPDATE #{self.class.table_name}
    SET #{self.class.attributes.map { |attribute| attribute.id2name}.join(" = ?, ")} = ?
    WHERE id = #{id}
    SQL
    DBConnection.execute(query, *attribute_values)
  end

  def attribute_values
    self.class.attributes.map {|attribute| send(attribute)}
  end
end
