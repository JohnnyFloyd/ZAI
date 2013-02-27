class VisitsController < ApplicationController
  protect_from_forgery
  load_and_authorize_resource
  # GET /visits
  # GET /visits.json
  def index
    @visits = Visit.all
    @hairdressers = []
    @users = []
    @hours = []
    @visits.each do |visit|
      @hairdressers.append(User.find(visit.hairdresser))
      @users.append(User.find(visit.client))
      @hours.append(get_date(visit.visit_date,visit.workhours[0]))
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visits }
    end
  end
  
  def client_visits
    @visits = Visit.where("client = ?",current_user.id).order("visit_date DESC")
    @hairdressers = []
    @hours = []
    @visits.each do |visit|
      @hairdressers.append(User.find(visit.hairdresser))
      @hours.append(get_date(visit.visit_date,visit.workhours[0]))
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visits }
    end
  end
  
  def hairdresser_visits
    @visits = Visit.where("hairdresser = ? and confirmed = ?",current_user.id, true)
    @users = []
    @hours = []
    @visits.each do |visit|
      @users.append(User.find(visit.client))
      @hours.append(get_date(visit.visit_date,visit.workhours[0]))
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visits }
    end
  end

  # GET /visits/1
  # GET /visits/1.json
  def show
    @visit = Visit.find(params[:id])
    @hour = get_date(@visit.visit_date,@visit.workhours[0])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @visit }
    end
  end

  # GET /visits/new
  # GET /visits/new.json
  def new
    @date = Date.current.beginning_of_week
    @hairdressers = getHairdressers
    @duration = DLUGOSC_WIZYTY
    @hours = getHours
    @chooseHour = params["hdress"] ? true : false
    
    if params["next"] == "true"
      @date = Date.parse(params["date"]).beginning_of_week.next_week
    elsif params["previous"] == "true"
      @date = Date.parse(params["date"]).beginning_of_week.prev_week
    end
    
    if params["chosen_hour"] and contains_true(params["chosen_hour"])
      visit_from_params(params)
    else
      if params["hdress"] then
        chosen_h = User.find_by_id(params["hdress"].to_i)
        @schedule = updateSchedule(chosen_h,params["duration"].to_i,@date)
        @chosenID = params["hdress"]
        @mode = params["duration"]
      end
      
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @visit }
      end
    end
  end
  
  def choose_duration
    @duration = DLUGOSC_WIZYTY
  end
  
  def quick_choice
    if params["hdress"]
      visit_from_params(params, false)
    else
      @duration = set_duration(params["duration"])
      date_only, @workhour, @hairdresser = get_closest_time(@duration)
      @date = get_date(date_only, @workhour)
    end
  end
  
  def confirm
    print params
    visit = Visit.find_by_id(params["id"].to_i)
    if visit.register_time + 600 > Time.now
      other_visits = Visit.where("id != ? AND hairdresser = ? AND confirmed = ?", visit.id, visit.hairdresser.id,true)
      other_visits.each do |other|
        for workhour in visit.workhours
          for other_workhour in other.workhours
            if get_date(visit.visit_date,workhour) == get_date(other.visit_date,other_workhour)
              respond_to do |format|
                flash[:error] = "Niestety na ta godzine jest juz potwierdzona wizyta. Umow sie w innym terminie."
                format.html { redirect_to visit }
                format.xml  { render :xml => @visit.error, :status => :unprocessable_entity }
              end
              return
            end
          end
        end
      end
      visit.confirm
      visit.save
    end
    respond_to do |format|
        format.html { redirect_to visit_path, notice: 'Wizyta zostala potwierdzona.' }
    end
  end
  
  # GET /visits/1/edit
  def edit
    @visit = Visit.find(params[:id])
  end

  # POST /visits
  # POST /visits.json
  def create
    @visit = Visit.new(params[:visit])

    respond_to do |format|
      if @visit.save
        format.html { redirect_to @visit, notice: 'Visit was successfully created.' }
        format.json { render json: @visit, status: :created, location: @visit }
      else
        format.html { render action: "new" }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /visits/1
  # PUT /visits/1.json
  def update
    @visit = Visit.find(params[:id])

    respond_to do |format|
      if @visit.update_attributes(params[:visit])
        format.html { redirect_to @visit, notice: 'Visit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visits/1
  # DELETE /visits/1.json
  def destroy
    @visit = Visit.find(params[:id])
    @visit.destroy

    respond_to do |format|
      format.html { redirect_to visits_url }
      format.json { head :no_content }
    end
  end

  private
  
  def contains_true(params)
    for b in params
      if b[1].value?("true")
        return true
      end
    end
    return false
  end
  
  def getHairdressers
    set = Role.find_by_role_name(:hairdresser).users
    hairdressers = set.map { |hdress| [hdress.name + " " + hdress.surname, hdress.id] }
    return hairdressers
  end
  
  def create_quick_visit(params)
      hairdresser = User.find_by_id(params["hairdresser"].to_i)
      visit_date = params["date"].to_date.to_s(:db)
      duration = params["duration"].to_i
      workhours = []
      workhours.append(get_workhour_from_date(Time.parse(params["date"])))
      if duration == 2
        print workhours, " ", workhours[0], " ", workhours[0][0]
        workhours.append(get_next_workhour(workhours[0]))
      end
      visit = Visit.new({ :hairdresser => hairdresser, :visit_date => visit_date, :client => current_user, :register_time => Time.now})
      visit.set_workhours(workhours)
  end
  
  def get_closest_time(duration)
    hairdressers = Role.find_by_role_name(:hairdresser).users
    current_date = Date.current + 10.years
    current_workhour = hairdresser = ""
    for hdress in hairdressers
        date, workhour = get_closest_time_for_hairdresser(hdress,@duration)
        print date," ", workhour.id, "\n"
        if date < current_date
          print "TO TA\n"
          current_date = date
          current_workhour = workhour
          hairdresser = hdress
        end
    end
    return current_date, current_workhour, hairdresser
  end
  
  def get_closest_time_for_hairdresser(hairdresser,duration = 1)
    date = Date.current + 10.year
    result = ""
    for workhour in hairdresser.workhours
      new_date = get_first_free_day(workhour,hairdresser,duration)
      if new_date < date
        date = new_date
        result = workhour
      end
    end
    return date, result
  end
  
  def get_first_free_day(workhour, hairdresser,duration)
    best_date = get_best_date(workhour)
    sorted_visits = workhour.visits.order("visit_date")
    
    if sorted_visits.size == 0 and duration > 1
        best_date = update_best_date_for_longer(best_date,hairdresser,workhour)
    elsif sorted_visits.size > 0
      for visit in sorted_visits
        if !visit.confirmed
          next
        end
        best_date = update_best_date(best_date,hairdresser,visit)
        if duration > 1
          best_date = update_best_date_for_longer(best_date,hairdresser,workhour)
        end
        best_date = update_for_client_visits(workhour,best_date)
      end
    end
    return best_date
  end
  
  def get_best_date(workhour)
    best_date = get_date(Date.current,workhour)
    if best_date.past?
      best_date = get_date(Date.current + 7,workhour)
    end
    best_date = update_for_client_visits(workhour, best_date.to_date)
    return best_date
  end
  
  def update_best_date(best_date,hairdresser,visit)
    if visit.hairdresser == hairdresser and visit.visit_date == best_date
      best_date += 1.week
    end
    return best_date
  end
  
  def update_best_date_for_longer(best_date,hairdresser,workhour)
    next_workhour = hairdresser.workhours.find_by_id(workhour.id + 1)
    if next_workhour
      visits = next_workhour.visits.where("hairdresser = ? AND visit_date > ? AND visit_date < ? AND confirmed = ?",hairdresser.id,best_date,best_date + 1,true)
      if visits.size > 0
        best_date += 1.week
      end
    else
      best_date += 1000.years
    end
    return best_date
  end
  
  
  def update_for_client_visits(workhour, best_date)
    for visit in workhour.visits
      if visit.id == current_user.id and visit.visit_date == best_date and visit.workhours.include?(workhour)
        best_date += 1.week
        break
      end
    end
    return best_date
  end
  
  def get_workhours_from_schedule(sched, duration = 0)
    hours = []
    for day in sched
        for hour in day[1]
          if hour[1] == "true"
            if duration >0
              hours.append(Workhour.where(:day => day[0].to_i, :hour => hour[0].to_i).first)
              if duration >1
                hours.append(Workhour.where(:day => day[0].to_i, :hour => hour[0].to_i + 1).first)
              end
              return hours
            else
              return Workhour.where(:day => day[0].to_i, :hour => hour[0].to_i).first
            end
          end
        end
    end
    return nil
  end
  
  def get_workhours_from_date(date,duration)
    workhours = []
    weekday = (date.to_date - date.to_date.beginning_of_week).to_i
    hour = (date.to_time.seconds_since_midnight/3600 - START_HOUR).to_i
    first = Workhour.where("day = ? AND hour = ?",weekday,hour)[0]
    workhours.append(first)
    
    if duration > 1
      second = get_next_workhour(first)
      workhours.append(second)
    end
    return workhours
  end
  
  def updateSchedule(hairdresser, duration, date)
    schedule = getSchedule(nil)
    workhours = hairdresser.workhours
    for el in workhours
      visit_date = get_date(date,el)
      if visit_date.future? and hour_for_hairdresser_free?(hairdresser.id, el,visit_date) and hour_for_client_free?(el)
        schedule[el.day][el.hour] = true
      end
    end
    if duration > 1
      schedule = edit_schedule_for_duration(schedule)
    end
    return schedule
  end
  
  def hour_for_client_free?(workhour)
    for visit in workhour.visits
      if visit.client.id == current_user.id
        return false
      end
    end
    return true
  end
  
  def hour_for_hairdresser_free?(hdress_id, workhour,visit_date)
    for visit in workhour.visits
      if !visit.confirmed
        next
      end
      if visit.hairdresser.id == hdress_id and get_date(visit.visit_date,workhour) == visit_date
        return false
      end
    end
    return true
  end
  
  def set_duration(duration)
    if duration == "1"
      return 1
    else
      return 2
    end
  end
  
  def edit_schedule_for_duration(schedule)
    for day in 0..(schedule.size-1)
        for hour in 0..(schedule[day].size-1)
          #print schedule[day][hour]
          if schedule[day][hour] == true and hour < (schedule[day].size-1)
            if schedule[day][hour+1] == false
              schedule[day][hour] = false
            end
          else
            schedule[day][hour] = false
          end
        end
    end
    schedule
  end
  
  def get_date(date, workhour)
    date = date.beginning_of_week + workhour.day
    date = date.to_time + (START_HOUR+workhour.hour).hours
  end
  
  def visit_from_params(params, schedule = true)
    hairdresser = params["hdress"].to_i
    duration = params["duration"].to_i
    begin
      if schedule
        chosen_hour = params["chosen_hour"]
        visit_date = get_visit_date_from_schedule(Date.parse(params["date"]),chosen_hour)
        workhours = get_workhours_from_schedule(chosen_hour,duration)
      else
        visit_date = Time.parse(params["date"])
        workhours = get_workhours_from_date(visit_date,duration)
      end
      create_new_visit(hairdresser,workhours,visit_date)
    rescue ArgumentError => e
      print e.message
      respond_failure
    end
  end
  
  def respond_failure
    respond_to do |format|
      format.html { redirect_to(root_path, :notice => 'Nie powiodla sie rejestracja - wprowadzono bledne dane') }
      format.xml  { render :xml => visit, :status => :unprocessable_entity }
    end
  end
  
  def get_visit_date_from_schedule(date, chosen_hour)
    workhour = get_workhours_from_schedule(chosen_hour)
    return get_date(date, workhour)
  end
  
  def create_new_visit(hairdresser, workhours, visit_date)
      visit = Visit.new({:client => current_user , :hairdresser => User.find_by_id(hairdresser), :confirmed => false, :visit_date => visit_date})
      visit.set_register_time(Time.now.utc.localtime)
      visit.set_workhours(workhours)
      
      respond_to do |format|
        if visit.validate and visit.save
          format.html { redirect_to(visit, :notice => 'Zostala utworzona wizyta') }
          format.xml  { render :xml => visit, :status => :created, :location => visit }
        else
          format.html { redirect_to(new_visit_path, :notice => 'Nie powiodla sie rejestracja - wprowadzono bledne dane') }
          format.xml  { render :xml => visit, :status => :unprocessable_entity }
        end
      end
  end
  
  def get_next_workhour(workhour)
    if workhour != Workhour.last
      print "\n",workhour, "\n"
      next_workhour = Workhour.where("day = ? AND hour = ?",workhour.day,workhour.hour + 1)
      if next_workhour == nil
        next_workhour = Workhour.where("day = ? AND hour = ?",workhour.day + 1,0)
      end
      return next_workhour[0]
    else
      return Workhour.first
    end
  end

end
