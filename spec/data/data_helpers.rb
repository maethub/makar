module DataHelpers

  # Loads the schema file 'name'
  def load_schema(name)
    File.read('./spec/data/schemas/' + name)
  end
end