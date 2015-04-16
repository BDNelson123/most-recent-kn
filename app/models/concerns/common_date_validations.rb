module CommonDateValidations
  extend ActiveSupport::Concern

  included do
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
end
