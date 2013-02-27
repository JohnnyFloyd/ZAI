namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    
    WORKDAYS.times do |n|
      if n < SATURDAY
        WORKDAY_HOURS.times do |x|
          Workhour.create!(day: n, hour: x)
        end
      else
        SATURDAY_HOURS.times do |x|
          Workhour.create!(day: n, hour: x)
        end
      end
    end
    list = [:client, :hairdresser, :admin, :none]
    for name in list
      role = Role.new
      role.role_name = name
      role.save
    end
    
    user = User.create!(name: "Wielki", surname: "Brat",
                 email: "admin@ultra.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:admin)
    
    user = User.create!(name: "Jan", surname: "kinder",
                 email: "banan8p@tlen.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: false)
                 
    user.add_role(:client)
    
    user = User.create!(name: "Fryzjer", surname: "Lolendo",
                 email: "banan8p@o2.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:hairdresser)
    user.set_workhours(Workhour.all[1..15])
    
    user = User.create!(name: "Golarz", surname: "Filip",
                 email: "carbonara2@o2.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:hairdresser)
    user.set_workhours(Workhour.all[11..41])
    
    user = User.create!(name: "Sweeney", surname: "Todd",
                 email: "carbonara3@o2.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:hairdresser)
    user.set_workhours(Workhour.all[20..40])
    
    user = User.create!(name: "Trololo", surname: "Man",
                 email: "carbonara4@o2.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:hairdresser)
    user.set_workhours(Workhour.all[40..53])
    
    user = User.create!(name: "Derpina", surname: "Derpette",
                 email: "carbonara5@o2.pl",
                 password: "szynka",
                 password_confirmation: "szynka",
                 confirmed: true)
                 
    user.add_role(:hairdresser)
    user.set_workhours(Workhour.all[33..51])
  end
end
