class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def getSchedule(workhours)
    schedule = []
    for i in 0..(WORKDAYS - 1)
      schedule.append([])
      for x in 0..(WORKDAY_HOURS-1)
        schedule[i].append(false)
      end
    end
    if workhours != nil
      for el in workhours
        schedule[el.day][el.hour] = true
      end
    end
    return schedule
  end
  
  
  def getMonday
    now = Time.now
    (now - 24*3600*now.wday + 24*3600).beginning_of_day
  end

  def getHours
    monday = getMonday
    hour_in_sec = 3600
    week = []
    hour = monday + START_HOUR*hour_in_sec

    for i in 0..(WORKDAYS - 1)
      day = []
      for delay in 0..(WORKDAY_HOURS-1)
        if i < (WORKDAYS - 1) or (i == (WORKDAYS - 1) and delay < SATURDAY_HOURS)
        day.append(hour + delay*hour_in_sec)
        elsif delay >= SATURDAY_HOURS
        day.append("")
        end
      end
      hour = hour + 24*hour_in_sec
      week.append(day)
    end

    return week
  end
  
end
