class Bay < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :bay_kind
  belongs_to :bay_status
  has_many :assignments

  validates :floor, :presence => true
  validates :floor, :inclusion => {:in => [1, 2, 3], :message => "must be 1, 2, or 3"}
  validates :number, :presence => true
  validates_uniqueness_of :number, :case_sensitive => false, :scope => :floor
  validates :bay_kind_id, :presence => true
  validates_model_id :bay_kind_id, :message => "must be a valid bay kind", :model => BayKind
  validates :bay_status_id, :presence => true
  validates_model_id :bay_status_id, :message => "must be a valid bay status", :model => BayStatus

  scope :common_attributes, -> { select('
      bays.id,bays.number,bays.id,bays.floor,bay_statuses.name as status_name,bay_statuses.description as status_description,
      bay_kinds.name as kind_name,bay_kinds.description as kind_description,bay_kinds.credits_per_hour as kind_credit'
    )
  }

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("bays.number LIKE ? OR bay_statuses.name LIKE ? OR bays_statuses.description LIKE ? OR bay_kinds.name LIKE ? OR bay_kinds.description LIKE ? OR bay_kinds.credits_per_hour LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    nil
  }

  scope :floor_preference, -> (params) {
    if params[:floor] != nil
      return where(:floor => params[:floor])
    end
    nil
  }

  scope :number_preference, -> (params) {
    if params[:number] != nil
      return where(:number => params[:number])
    end
    nil
  }

  def self.bay_waiting(bay,waiting,status)
    if status.to_i != 2
      if waiting.floor != nil && waiting.number != nil && waiting.floor.to_i == bay.floor.to_i && waiting.number.to_i == params[:bay][:number].to_i
         return true
      elsif waiting.floor != nil && waiting.number == nil && waiting.floor.to_i == bay.floor.to_i
        return true
      elsif waiting.floor == nil && waiting.number == nil
        return true
      else
        return false
      end
    else
      false
    end
  end
end
