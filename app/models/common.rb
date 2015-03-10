class Common
  # model: User
  # this is to put all the club ids into an array
  def self.club_array
    clubs = Club.all
    array = []

    clubs.each do |t|
      array.push(t.id)
    end

    return array
  end
end
