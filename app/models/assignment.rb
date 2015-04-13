class Assignment < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :bay
  belongs_to :user

  validates :bay_id, :presence => true
  validates :user_id, :presence => true
  validates :credits_per_hour, :presence => true
  validates :check_in_at, :presence => true
  validates :check_out_at, :presence => true
  validates :status_id, :presence => true
  validates_model_id :bay_id, :message => "must be a valid bay", :model => Bay
  validates_model_id :user_id, :message => "must be a valid user", :model => User
  validates :status_id, :inclusion => {:in => [0, 1], :message => "must be active or inactive"} # 0 for inactive, and 1 for active
  validate :check_out_date_before_check_in_date
  validate :check_out_date_length
  validate :check_in_past
  validate :check_out_past

  scope :common_attributes, -> { select('
    assignments.id, 
    assignments.bay_id,
    assignments.credits_per_hour as assignments_credits_per_hour,
    assignments.check_in_at,
    assignments.check_out_at,
    assignments.status_id,
    bays.number as bays_number, 
    bay_kinds.name as bay_kinds_name, 
    bay_kinds.description as bay_kinds_description,
    bay_statuses.name as bay_statuses_name, 
    bay_statuses.description as bay_statuses_description,
    users.name as users_name,
    users.email as users_email
  ')}

  scope :assignment_join, -> { 
    joins(:bay,:user,"
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

  private

  # check out date must be after check in date
  def check_out_date_before_check_in_date
    errors.add(:check_out_at, "must be after check in at") if
      check_in_at > check_out_at
  end

  # can only reserve bay for 12 hours
  def check_out_date_length
    errors.add(:check_out_at, "must be less than 12 hours after check in at") if
      check_out_at > (check_in_at + 12.hours)
  end

  # can not have check_in_at in the past
  def check_in_past
    errors.add(:check_in_at, "cannot be in the past") if
      check_in_at < Time.now
  end

  # can not have check_out_at in the past
  def check_out_past
    errors.add(:check_out_at, "cannot be in the past") if
      check_out_at < Time.now
  end
end
