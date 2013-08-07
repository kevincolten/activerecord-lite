require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :foreign_key, :primary_key
  def initialize(name, params)
    @other_class_name = params[:class_name] ||= "#{name}".camelize
    @primary_key = params[:primary_key] ||= :id
    @foreign_key = params[:foreign_key] ||= "#{name}_id".to_sym
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :foreign_key, :primary_key
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] ||= "#{name}".singularize.camelize
    @primary_key = params[:primary_key] ||= :id
    @foreign_key = params[:foreign_key] ||= "#{self_class}".underscore + "_id".to_sym
  end

  def type
  end
end

module Associatable

  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    define_method(name) do
      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.primary_key} = ?
      SQL
      results = DBConnection.execute(query, self.send(aps.foreign_key))
      aps.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
    define_method(name) do
      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.foreign_key} = ?
      SQL
      results = DBConnection.execute(query, self.send(aps.primary_key))
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
