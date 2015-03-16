class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :omniauthable, :confirmable
  include DeviseTokenAuth::Concerns::User

  has_one :level
  has_one :package
  has_one :course
  has_one :wood_club, class_name: "Club", foreign_key: :wood_club_id
  has_one :iron_club, class_name: "Club", foreign_key: :iron_club_id
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
  validates_model_id :iron_club_id, :message => "must be a valid club brand", :model => Club
  validates :wood_club_id, :presence => true
  validates_model_id :wood_club_id, :message => "must be a valid club brand", :model => Club
  validates :level_id, :presence => true
  validates_model_id :level_id, :message => "must be a valid level option", :model => Level
  validates :handedness, :inclusion => {:in => [true, false], :message => "must be left or right"} # 0 for left, and 1 for right
  validates :gender, :inclusion => {:in => [true, false], :message => "must be male or female"} # 0 for female, and 1 for male
  validates :email, :presence => true
  validates_email_format_of :email
  validates :email_optin, :inclusion => {:in => [true, false], :message => "must be yes or no"}
  validates :terms_accepted, :inclusion => {:in => [true, false], :message => "must be yes or no"}
  validates :income_id, :presence => true
  validates_model_id :income_id, :message => "must be a valid income option", :model => Income

  scope :common_attributes, -> { select('name, nickname, image, email, address, address2, city, state, zip, phone, dob, handedness, owns_clubs, email_optin, terms_accepted, gender')}
end
