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
    result = DBConnection.execute(<<-SQL)
      SELECT *
      FROM "#{self.table_name}"
    SQL
    parse_all(result)

  end

  def self.parse_all(results)
    parsed = []

    results.each do |hash|
      parsed << self.new(hash)
    end
    parsed
  end

  def self.find(id)
    results= DBConnection.execute(<<-SQL)
      SELECT *
      FROM "#{self.table_name}"
      WHERE id = "#{id}"
    SQL
      parse_all(results).first
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |key, value|
      if columns.include?(key.to_sym)
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
    attributes.values
  end

  def insert
    columns = self.class.columns.drop(1)
    id = self.class.columns.first
    col_names = columns.join(', ')
    question_marks = []
    columns.length.times do
      question_marks << "?"
    end
    joint = question_marks.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
      (#{joint})
    SQL

    attributes[id] = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns.map{|column| "#{column} = ?"}.drop(1)
    row = columns.join(', ')
    id = self.class.columns.first

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      UPDATE
        #{self.class.table_name}
      SET
        #{row}
      WHERE
        id = #{attributes[:id]}
    SQL
  end

  def save
    if attributes[:id].nil?
      insert
    else
      update
    end
  end
end
