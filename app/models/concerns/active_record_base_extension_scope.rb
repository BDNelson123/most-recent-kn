module ActiveRecordBaseExtensionScope
  extend ActiveSupport::Concern

  included do
    scope :where_attributes, -> (params) { 
      if params[:where] != nil
        return where(params[:where])
      end
      nil
    }

    scope :main_index, -> (params) {
      if params[:count] == "true"
        { :count => where_attributes(params).count }
      else
        where_attributes(params).paginate(:page => params[:page], :per_page => params[:per_page]).common_attributes.all.order("#{params[:order_by]} #{params[:order_direction]}")
      end
    }
  end
end
