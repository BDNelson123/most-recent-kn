class Bay < ActiveRecord::Base
  belongs_to :bay_type
  belongs_to :bay_status
end
