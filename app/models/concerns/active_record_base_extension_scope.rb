module ActiveRecordBaseExtensionScope
  extend ActiveSupport::Concern

  included do
    scope :where_attributes, -> (params) { 
      if params[:query] != nil
        where(params[:query])
      else
        nil
      end
    }
  end
end
