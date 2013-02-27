module ApplicationHelper
  
  def print_weekdays(date)
    output = ""
    for i in 0..WEEKDAYS.size-1
       output += "<th>"
       output += WEEKDAYS[i] + " " + (date + i).to_s
       output += "</th>"
    end
    return output.html_safe
  end
end
