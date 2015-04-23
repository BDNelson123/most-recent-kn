class Assignment < ActiveRecord::Base
  attr_accessor :bay_kind_id, :floor, :number, :duration

  include ActiveRecordBaseExtensionScope
  include CommonDateValidations

  belongs_to :bay
  belongs_to :user
  belongs_to :parent, class_name: "Assignment"
  has_many :assignments, class_name: "Assignment", foreign_key: :parent_id
  before_create :delete_assignments_for_user_before_creating_new_one

  validates :bay_id, :presence => true
  validates :user_id, :presence => true
  validates :credits_per_hour, :presence => true
  validates_numericality_of :credits_per_hour, :if => :credits_per_hour
  validates :check_in_at, :presence => true
  validates :check_out_at, :presence => true
  validates_uniqueness_of :bay_id
  validates_uniqueness_of :user_id
  validates_model_id :bay_id, :message => "must be a valid bay", :model => Bay, :if => :bay_id?
  validates_model_id :user_id, :message => "must be a valid user", :model => User, :if => :user_id?
  validates_model_id :parent_id, :message => "must be a valid assignment", :model => Assignment, :if => :parent_id?
  validate :check_out_date_before_check_in_date, :if => lambda { |t| t.check_in_at? && t.check_out_at? }
  validate :check_out_date_length, :if => lambda { |t| t.check_in_at? && t.check_out_at? }
  validate :check_in_past, :if => :check_in_at?
  validate :check_out_past, :if => :check_out_at?

  scope :common_attributes, -> { 
    select('
      assignments.id, 
      assignments.bay_id,
      assignments.user_id,
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

  private

  # makes sure to delete any assignment for a user before creating a new one
  def delete_assignments_for_user_before_creating_new_one
    Assignment.where(['user_id = ? AND bay_id <> ?', self.user_id, self.bay_id]).destroy_all
  end
end
