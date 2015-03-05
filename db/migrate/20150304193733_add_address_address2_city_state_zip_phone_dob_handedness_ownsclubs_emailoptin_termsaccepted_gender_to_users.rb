class AddAddressAddress2CityStateZipPhoneDobHandednessOwnsclubsEmailoptinTermsacceptedGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :integer
    add_column :users, :phone, :string
    add_column :users, :dob, :date
    add_column :users, :handedness, :boolean
    add_column :users, :owns_clubs, :boolean
    add_column :users, :email_optin, :boolean
    add_column :users, :terms_accepted, :boolean
    add_column :users, :gender, :boolean
  end
end
