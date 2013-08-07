class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    self.new_attr_accessor(*attributes)
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    p results
    results.map do |result|
      self.new(result)
    end
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.attributes.include?(attr_name.to_sym)
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
      self.send("#{attr_name}=".to_sym, value)
    end
  end

  def self.new_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method("#{attribute}") do
        instance_variable_get("@#{attribute}")
      end

      define_method("#{attribute}=") do |var|
        instance_variable_set("@#{attribute}", var)
      end
    end
  end

end