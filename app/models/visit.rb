class Visit < ActiveRecord::Base
  attr_accessible :visit_date, :client, :hairdresser, :confirmed, :register_time
  validates_presence_of :client, :hairdresser
  belongs_to :hairdresser, :class_name => "User", :foreign_key => "hairdresser"
  belongs_to :client, :class_name => "User", :foreign_key => "client"
  has_and_belongs_to_many :workhours
  
  def set_workhours(hours)
    self.workhours = hours
  end
  
  def set_register_time(time)
    self.register_time = time
  end
  
  def confirm
    self.confirmed = true
  end
  
  def validate
    if self.visit_date.past? or self.hairdresser.roles.include?(:hairdresser) == 0
      return false
    end
    
    for workhour in self.workhours
      if !self.hairdresser.workhours.include?(workhour)
        return false
      end
    end
    #print self.hairdresser.id, " ", self.client.id, " ",self.workhours[0].id, " ", self.hairdresser
    for workhour in self.workhours
      for hdress_visit in Visit.where("hairdresser = ?",hairdresser.id)
        if hdress_visit.workhours.include?(workhour)
          return false
        end
      end
    end
    return true 
  end
  
end
