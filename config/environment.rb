# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SalonFryz::Application.initialize!

SATURDAY = 5
WORKDAYS = 6
WORKDAY_HOURS = 10
SATURDAY_HOURS = 6
START_HOUR = 10
WEEKDAYS = ["Poniedzialek","Wtorek","Sroda","Czwartek","Piatek","Sobota"]
DLUGOSC_WIZYTY = [["1 godzina",1],["2 godziny",2]]
