# == Schema Information
#
# Table name: institutional_users
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  country              :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  number_of_classrooms :integer
#  children_impacted    :integer
#  organization_name    :string(255)
#  city                 :string(255)
#

class InstitutionalUser < ActiveRecord::Base

	belongs_to :user

	validates :country, presence: true
	#validates :city, presence: true
	validates :organization_name, presence: true
	validates :number_of_classrooms, presence: true
	validates :children_impacted, presence: true 

end
