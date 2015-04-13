class User < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :omniauthable, :confirmable
  include DeviseTokenAuth::Concerns::User

  belongs_to :level
  belongs_to :package # NOTE: package is not required on create - reason for left join in user_join
  belongs_to :course # NOTE: favorite course is not required on create - reason for left join in user_join
  belongs_to :wood_club, class_name: "Club", foreign_key: :wood_club_id
  belongs_to :iron_club, class_name: "Club", foreign_key: :iron_club_id
  belongs_to :income
  has_many :assignments

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

  scope :common_attributes, -> { select('
      users.id, users.name as user_name, users.nickname, users.image, users.email, users.address, users.address2, 
      users.city, users.state, users.zip, users.phone, users.dob, users.handedness, users.owns_clubs, 
      users.email_optin, users.terms_accepted, users.gender, users.level_id, levels.name as level_name,
      iron_club.id as iron_club_id, iron_club.name as iron_club_name, wood_club.id as wood_club_id, 
      wood_club.name as wood_club_name, users.course_id, courses.name as course_name, users.income_id, 
      incomes.name as income_name, users.package_id, packages.name as packages_name
    ')
  }

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("
        users.name LIKE ? OR users.address LIKE ? OR users.address2 LIKE ? OR
        users.city LIKE ? OR users.state LIKE ? OR users.zip LIKE ? OR
        users.phone LIKE ? OR users.dob LIKE ? OR users.email LIKE ? OR
        iron_club.name LIKE ? OR packages.name LIKE ?", 
        "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%",
        "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%",
        "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"
      )
    end
    nil
  }

  scope :user_join, -> { joins(:level,:income,"
      JOIN clubs iron_club ON users.iron_club_id = iron_club.id 
      JOIN clubs wood_club ON users.wood_club_id = wood_club.id 
      LEFT JOIN courses ON users.course_id = courses.id
      LEFT JOIN packages ON users.package_id = packages.id
      LEFT JOIN featurizations ON users.package_id = featurizations.id 
      LEFT JOIN features ON featurizations.feature_id = features.id
    ")
  }

  scope :user_group, -> (params) { 
    if params[:count] != "true"
      return group("users.id")
    end
    nil
  }

  def self.find_user(params)
    case params[:type]
      when "email"
        User.user_join.common_attributes.find_by_email(params[:id])
      when "phone"
        User.user_join.common_attributes.find_by_phone(params[:id])
      else
        User.user_join.common_attributes.find_by_id(params[:id])
    end
  end
end
