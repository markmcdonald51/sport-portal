class Ability
  include CanCan::Ability
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  # You will usually be working with these four actions.
  # These aren't the same as the 7 RESTful actions in Rails!
  # CanCanCan automatically adds some convenient aliases for mapping the controller actions.
  # https://github.com/CanCanCommunity/cancancan/wiki/Action-Aliases
  #  `alias_action :index, :show, :to => :read`
  #  `alias_action :new, :to => :create`
  #  `alias_action :edit, :to => :update`
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

  def initialize(user, team_member = nil)
    # Define abilities for the passed in user here. For example:
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end

    user ||= User.new # guest user (not logged in)
    id = user.id

    # All users can only update their own user attributes
    user_id = user.id
    can :update, User, id: user_id

    can :read, Team, private: false

    if user.present?
      can :create, Team
      can :read, Team, private: true, members: { id: user_id }
      can :update, Team, members: { id: user_id }
      can :destroy, Team, owners: { id: user_id }
    end

    can :assign_ownership, Team, Team do |team|
      team.owners.include? user
    end

    can :delete_ownership, Team, Team do |team|
      team.owners.include? user
      team.owners.length > 1
    end

    can :delete_membership, Team, Team do |team|
      team.owners.include? user and Ability.number_of_owners_after_delete(team, team_member) > 0
    end

    can :delete_membership, Team, Team do |team|
      Integer(id) == team_member and Ability.number_of_owners_after_delete(team, team_member) > 0
    end
  end

  private
    def self.number_of_owners_after_delete(team, team_member)
      owners = team.owners
      another_user = User.find(team_member)
      if owners.include? another_user
        owners_after_delete = owners - [another_user]
      else
        owners_after_delete = owners
      end
      owners_after_delete.length
    end
end
