require 'pry'

class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    if @id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL
      
      DB[:conn].execute(sql, @name, @breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    
    self
  end
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?;
    SQL
    
    # Check if dog exists with the given name and breed
    dog_data = DB[:conn].execute(sql, name, breed).first
    
    if dog_data
      self.new_from_db(dog_data)
    else
      self.create(name: name, breed: breed)
    end
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    
    self.new(name: name, breed: breed, id: id)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL
    
    dog_data = DB[:conn].execute(sql, id).first
    self.new_from_db(dog_data)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    
    dog_data = DB[:conn].execute(sql, name).first
    self.new_from_db(dog_data)
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?,
          breed = ?
      WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, @name, @breed, @id)
  end
end