class UsersController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def list_to_confirm
    @users = User.where("confirmed != ?",true)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def confirm_user
    @user = User.find_by_id(params["user_id"])
    @user.confirm
    respond_to do |format|
      if @user.save
        format.html { redirect_to( list_to_confirm_path, :notice => 'Uzytkownik zostal zaakceptowany') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "list_to_confirm" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def manage_schedule
    user = User.find(params[:user_id])
    @schedule = getSchedule(user.workhours)
    if params["changed_schedule"]
      success, message = update_schedule_from_params(user, params)
      respond_to do |format|
        if success
          flash[:succes] = message
        else
          flash[:error] = message
        end
        format.html { redirect_to( user_schedule_path) }
      end
    end
    @hours = getHours
  end
  
  def report
    @hairdressers = Role.find_by_role_name(:hairdresser).users
    visits = Visit.all
    @report_results = {}
    for hdress in @hairdressers
      @report_results[hdress.id] = { :hours => 0, :clients => [] }
    end
    
    for visit in visits
      if !visit.confirmed
        next
      end
      @report_results[visit.hairdresser.id][:hours] += 1
      if !@report_results[visit.hairdresser.id][:clients].include?(visit.client.id)
        @report_results[visit.hairdresser.id][:clients].append(visit.client.id)
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    user = User.new(params[:user])
    user.save
    user.confirm
    user.add_role(:hairdresser)
    print "DDDDDDDDDDDDDDDDDDDDDDDDDDddddupappppppppppppasdasdas", user.confirmed
    respond_to do |format|
      if user.save
        format.html { redirect_to(root_path, :notice => 'Udalo sie stworzyc fryzjera') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def update_schedule_from_params(user,params)
    workhours = []
    sched = params["changed_schedule"]
    
    for day in sched
      for hour in day[1]
        if hour[1] == "true"
          begin
            @schedule[day[0].to_i][hour[0].to_i] = true
          rescue
            error_text = "Bledne dane wejsciowe"
            return false, error_text
          end
          new_workhour = Workhour.where(:day => day[0].to_i, :hour => hour[0].to_i).first
          if new_workhour.users.size > 3 and !new_workhour.users.include?(user)
            error_text = "Godzina " + (hour[0].to_i + START_HOUR).to_s + " w "+ WEEKDAYS[day[0].to_i]+ " jest juz zajeta przez 4 pracownikow!"
            return false, error_text 
          end
          workhours.append(new_workhour)
        end
      end
    end
    if workhours.size > 40
      error_text = "Nie mozna pracowac wiecej niz 40 godzin tygodniowo!"
      return false, error_text
    else
      user.set_workhours(workhours)
      message = "Harmonogram pracy zostal zaktualizowany!"
      return true, message
    end
  end

end