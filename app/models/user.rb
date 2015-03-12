class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :omniauthable, :confirmable
  include DeviseTokenAuth::Concerns::User

  has_one :level
  has_one :package
  has_one :course
  has_one :club
  has_one :income
  has_one :bay

  validates :name, :presence => true
  validates :address, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true
  validates :phone, :presence => true, :numericality => { :only_intger => true }, :length => { maximum: 15, minimum: 10 }
  validates_date :dob, :before => lambda { 18.years.ago }, :before_message => "You must be at least 18 years old."
  validates :dob, :presence => true
  validates :owns_clubs, :inclusion => {:in => [true, false], :message => "must be yes or no"}
  validates :iron_club_id, :presence => true
  #validates_model_id :iron_club_id, :message => "must be a valid club brand", :model => Club
  validate :iron_wood_id
  validates :wood_club_id, :presence => true
  validate :include_wood_id
  validates :level_id, :presence => true
  validate :include_level_id
  # handedness has a value of 0 for left, and 1 for right
  validates :handedness, :inclusion => {:in => [true, false], :message => "must be left or right"}
  # gender has a value of 0 for female, and 1 for male
  validates :gender, :inclusion => {:in => [true, false], :message => "must be male or female"}
  validates :email, :presence => true
  validates_email_format_of :email
  validates :email_optin, :inclusion => {:in => [true, false], :message => "must be yes or no"}
  validates :terms_accepted, :inclusion => {:in => [true, false], :message => "must be yes or no"}
  validate :include_income_id

  scope :common_attributes, -> { select('name, nickname, image, email, address, address2, city, state, zip, phone, dob, handedness, owns_clubs, email_optin, terms_accepted, gender')}

  # custom validation for wood_club_id
  def include_wood_id
    errors.add(:wood_club_id, "must be a valid brand") unless Common.model_array(Club).include?(wood_club_id)
  end

  # custom validation for iron_club_id
  def include_iron_id
    errors.add(:iron_club_id, "must be a valid brand") unless Common.model_array(Club).include?(iron_club_id)
  end

  # custom validation for level_id
  def include_level_id
    errors.add(:level_id, "must be a valid level") unless Common.model_array(Level).include?(level_id)
  end

  # custom validation for level_id
  def include_income_id
    errors.add(:income_id, "must be a valid income") unless Common.model_array(Income).include?(income_id)
  end
end
