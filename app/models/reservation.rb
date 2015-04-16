class Reservation < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope
  include CommonDateValidations

  belongs_to :bay
  belongs_to :user
  belongs_to :parent, class_name: "Reservation"
  has_many :reservations, class_name: "Reservation", foreign_key: :parent_id

  validates :bay_id, :presence => true
  validate :bay_has_already_been_reserved
  validates :check_in_at, :presence => true
  validates :check_out_at, :presence => true
  validates_model_id :bay_id, :message => "must be a valid bay", :model => Bay
  validates_model_id :user_id, :message => "must be a valid user", :model => User
  validates_model_id :parent_id, :message => "must be a valid reservation", :model => Reservation, :if => :parent_id?
  validate :check_out_date_before_check_in_date
  validate :check_out_date_length
  validate :check_in_past
  validate :check_out_past
  validate :bay_has_already_been_reserved_checkin
  validate :bay_has_already_been_reserved_checkout

  private

  def bay_has_already_been_reserved_checkin
    errors.add(:check_in_at, "must not overlap with another reservation for this bay") if
      Reservation.where(:check_in_at => check_in_at...check_out_at).count > 0
  end

  def bay_has_already_been_reserved_checkout
    errors.add(:check_out_at, "must not overlap with another reservation for this bay") if
      Reservation.where(:check_out_at => check_in_at...check_out_at).count > 0
  end
end
