class Dog

  attr_reader :id
  attr_accessor :name, :breed

  def initialize(name: , breed: , id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
      return self
    else
      sql_save = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM dogs
        SQL
      DB[:conn].execute(sql_save, self.name, self.breed)
      @id = DB[:conn].execute(sql_id)[0][0]
      return self
    end
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id =?", id)[0]
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog
  end

  def self.find_or_create_by(name: name, breed: breed)
    dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_array.empty?
      dog = Dog.new_from_db(dog_array[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    return dog
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    Dog.new_from_db(dog_row)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
