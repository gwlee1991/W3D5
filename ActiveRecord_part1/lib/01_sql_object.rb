require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
      *
      FROM
      "#{table_name}"
    SQL
      .first.map{|column| column.to_sym}
  end

  def self.finalize!

    columns.each do |column|
      define_method (column) do
        attributes[column]
      end

      define_method ("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    "#{self} = #{table_name}"
  end

  def self.table_name
    "#{self}s".downcase
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |key, value|
      if columns.include?(key)
        self.send "#{key}=", value
      else
        raise "unknown attribute '#{key}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
