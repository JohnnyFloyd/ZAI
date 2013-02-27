class Workhour < ActiveRecord::Base
  attr_accessible :day, :hour
  has_and_belongs_to_many :users
  has_and_belongs_to_many :visits
end
