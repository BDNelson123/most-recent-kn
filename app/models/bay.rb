class Bay < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :bay_kind
  belongs_to :bay_status
  has_many :assignments

  validates :number, :presence => true
  validates_uniqueness_of :number, :case_sensitive => false
  validates :bay_kind_id, :presence => true
  validates_model_id :bay_kind_id, :message => "must be a valid bay kind", :model => BayKind
  validates :bay_status_id, :presence => true
  validates_model_id :bay_status_id, :message => "must be a valid bay status", :model => BayStatus

  scope :common_attributes, -> { select('bays.id, bays.number, bay_statuses.name as status_name, bay_statuses.description as status_description, bay_kinds.name as kind_name, bay_kinds.description as kind_description, bay_kinds.credits_per_hour as kind_credit')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("bays.number LIKE ? OR bay_statuses.name LIKE ? OR bays_statuses.description LIKE ? OR bay_kinds.name LIKE ? OR bay_kinds.description LIKE ? OR bay_kinds.credits_per_hour LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    nil
  }
end
