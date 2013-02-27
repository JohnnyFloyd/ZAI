class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :workhours
  has_many :visits
  #has_many :visits_client, :class_name => "Visit", :foreign_key => "visit_id"
  #has_many :visits_hairdresser, :class_name => "Visit", :foreign_key => "visit_id"
  after_create :confirm_false
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :surname, :cellphone, :avatar, :role_ids, :workhour_ids, :confirmed
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  def role?(role)
    return !!self.roles.find_by_role_name(role.to_s)
  end
  
  def confirm
    self.confirmed = true
    self.add_role(:client)
  end
  
  def set_workhours(hours)
    self.workhours = hours
  end
  
  def add_role(name)
    self.roles.clear
    roles = [].append(Role.find_by_role_name(name))
    self.roles = roles
  end
  
  private
  def confirm_false
    self.confirmed = false
    self.add_role(:none)
    self.save
  end
end