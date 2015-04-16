class Assignment < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope
  include CommonDateValidations

  belongs_to :bay
  belongs_to :user
  belongs_to :parent, class_name: "Assignment"
  has_many :assignments, class_name: "Assignment", foreign_key: :parent_id

  validates :bay_id, :presence => true
  validates_uniqueness_of :bay_id
  validates :user_id, :presence => true
  validates :credits_per_hour, :presence => true
  validates :check_in_at, :presence => true
  validates :check_out_at, :presence => true
  validates_model_id :bay_id, :message => "must be a valid bay", :model => Bay
  validates_model_id :user_id, :message => "must be a valid user", :model => User
  validates_model_id :parent_id, :message => "must be a valid assignment", :model => Assignment, :if => :parent_id?
  validate :check_out_date_before_check_in_date
  validate :check_out_date_length
  validate :check_in_past
  validate :check_out_past

  scope :common_attributes, -> { 
    select('
      assignments.id, 
      assignments.bay_id,
      assignments.credits_per_hour as assignments_credits_per_hour,
      assignments.check_in_at,
      assignments.check_out_at,
      bays.number as bays_number, 
      bay_kinds.name as bay_kinds_name, 
      bay_kinds.description as bay_kinds_description,
      bay_statuses.name as bay_statuses_name, 
      bay_statuses.description as bay_statuses_description,
      users.name as users_name,
      users.email as users_email
    ')
  }

  scope :assignment_join, -> { 
    joins(
      :bay,:user,"
      JOIN bay_kinds ON bays.bay_kind_id = bay_kinds.id
      JOIN bay_statuses ON bays.bay_status_id = bay_statuses.id
    ")
  }

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("
          assignments.credits_per_hour LIKE ? OR 
          assignments.check_in_at LIKE ? OR 
          assignments.check_out_at LIKE ? OR 
          users.name LIKE ? OR 
          users.email LIKE ?
        ", 
        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", 
        "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
    nil
  }
end
