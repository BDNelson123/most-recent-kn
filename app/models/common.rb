class Common
  # model: User
  # this is to put all the chosen model ids into an array
  def self.model_array(model)
    clubs = model.all
    array = []

    clubs.each do |t|
      array.push(t.id)
    end

    return array
  end
end
