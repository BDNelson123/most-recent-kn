class Bay < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :bay_type
  belongs_to :bay_status

  validates :number, :presence => true
  validates :bay_type_id, :presence => true
  validates_model_id :bay_type_id, :message => "must be a valid bay type", :model => BayType
  validates :bay_status_id, :presence => true
  validates_model_id :bay_status_id, :message => "must be a valid bay status", :model => BayStatus

  scope :common_attributes, -> { select('bays.id, bays.number, bay_statuses.name as status_name, bay_statuses.description as status_description, bay_types.name as type_name, bay_types.description as type_description, bay_types.credits_per_hour as type_credit')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("bays.number LIKE ? OR bay_statuses.name LIKE ? OR bays_statuses.description LIKE ? OR bay_types.name LIKE ? OR bay_types.description LIKE ? OR bay_types.credits_per_hour LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    nil
  }
end
