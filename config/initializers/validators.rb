ActiveRecord::Base.class_eval do
  def self.validates_model_id(*attr_names)
    options = attr_names.extract_options!

    validates_each(*attr_names, options) do |record, attr_name, value|
      record.errors.add(attr_name, options[:message]) unless Common.model_array(options[:model]).include?(value)
    end
  end
end
