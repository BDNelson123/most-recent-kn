class Waiting < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :user
  belongs_to :bay_kind
  belongs_to :parent, class_name: "Waiting"
  has_many :waitings, class_name: "Waiting", foreign_key: :parent_id

  validates :user_id, :presence => true
  validates_uniqueness_of :user_id, :if => :user_id?
  validates_model_id :user_id, :message => "must be a valid user", :model => User, :if => :user_id?
  validates :bay_kind_id, :presence => true
  validates_model_id :bay_kind_id, :message => "must be a valid bay kind", :model => BayKind, :if => :bay_kind_id?
  validates_presence_of :floor, :if => :number?
  validate :bay_on_floor, :if => :number?
  validates_model_id :parent_id, :message => "must be a valid waiting", :model => Waiting, :if => :parent_id?
  validates :duration, :presence => true
  validates_numericality_of :duration, :if => :duration
  validates :credits_per_hour, :presence => true
  validates_numericality_of :credits_per_hour, :if => :credits_per_hour

  scope :common_attributes, -> { 
    select('
      waitings.id,
      waitings.user_id,
      waitings.bay_kind_id,
      waitings.floor,
      waitings.number,
      bay_kinds.name as bay_kinds_name,
      bay_kinds.description as bay_kinds_description,
      bay_kinds.credits_per_hour as bay_kinds_credits_per_hour,
      users.name as users_name, 
      users.id as users_id,users.email as users_email
    ')
  }

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("
        users.name LIKE ? OR users.email LIKE ?","%#{params[:search]}%","%#{params[:search]}%"
      )
    end
    nil
  }

  scope :waiting_join, -> { joins(:user,:bay_kind) }

  def self.create_from_assignment(params)
    Waiting.new(
      :user_id => params[:user_id], 
      :bay_kind_id => params[:bay_kind_id], 
      :floor => params[:floor],
      :number => params[:number],
      :parent_id => params[:parent_id],
      :credits_per_hour => params[:credits_per_hour],
      :duration => params[:duration]
    )
  end

  private

  # make sure bay exists on that floor
  def bay_on_floor
    errors.add(:number, "does not exist on that floor") if
      Bay.where(:floor => floor, :number => number).count != 1
  end
end
