class Ability
  include CanCan::Ability
 
  def initialize(user)
    user ||= User.new # guest user

    if user.role? :admin
      can [:create, :delete, :list_to_confirm, :confirm_user, :report, :show, :edit, :new], User
      can [:delete, :index, :confirm_user, :report], Visit
    elsif user.role? :hairdresser
      can [:read, :edit, :update, :manage_schedule], User
      can [ :hairdresser_visits], Visit
    elsif user.role? :client
      can [:show, :edit, :update], User
      can [:show, :new, :confirm, :quick_choice, :choose_duration, :client_visits], Visit
    elsif user.role? :none
    end
  end
end