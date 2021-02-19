class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?);
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", self.name, self.breed)[0][0]
    self
  end

  def self.create(attr_hash)
    new_dog = self.new(attr_hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(arr)
    new_dog = self.new({id: arr[0], name: arr[1], breed: arr[2]})
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if new_dog
      new_dog = self.find_by_id(new_dog[0]).update
    else
      new_dog = self.create(name: name, breed: breed)
      new_dog.save
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      where id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self    
  end
end