class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :omniauthable, :confirmable
  include DeviseTokenAuth::Concerns::User

  validates :name, :presence => true
  validates :address, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true
  validates :phone, :presence => true
  validates_numericality_of :phone, :only_integer => true, :length => {maximum: 15}
  validates_date :dob, 
    :before => lambda { 18.years.ago },
    :before_message => "You must be at least 18 years old."
  validates :dob, :presence => true
  validates :owns_clubs, :inclusion => {:in => [true, false], :message => "must be yes or no"}

  # NOTE:
  # handedness has a value of 0 for left, and 1 for right
  validates :handedness, :inclusion => {:in => [true, false], :message => "must be left or right"}

  # NOTE:
  # gender has a value of 0 for female, and 1 for male
  validates :gender, :inclusion => {:in => [true, false], :message => "must be male or female"}

  validates :email, :presence => true
  validates_email_format_of :email
  validates_uniqueness_of :email
  validates :password, :presence => true
  validates :password_confirmation, :presence => true
end
