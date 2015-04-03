class Income < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :users

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
 
  scope :common_attributes, -> { select('id, name')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("incomes.name LIKE ?", "%#{params[:search]}%")
    end
    nil
  }
end
