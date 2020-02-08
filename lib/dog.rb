class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|k,v| self.send("#{k}=", v)}
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    self.new(attributes).tap {|dog| dog.save}
  end

  def self.new_from_db(row)
    attributes = {id: row[0], name: row[1], breed: row[2]}
    self.new(attributes)
  end

  def self.find_by_id(dog_id)
    sql = "SELECT * FROM dogs WHERE ?"
    result = DB[:conn].execute(sql, dog_id).first
    self.new_from_db(result)
  end

  def self.find_or_create_by(attributes)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    result = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !result.empty?
      dog = self.new_from_db(result.first)
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.find_by_name(dog_name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, dog_name).first
    self.new_from_db(result)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
