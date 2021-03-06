class User < Ohm::Model
  include Shield::Model
  include Ohm::Callbacks

  attribute :name
  attribute :username
  attribute :email
  attribute :crypted_password
  attribute :gravatar
  attribute :status

  index :status

  unique :username
  unique :email

  set :groups, :Group
  set :ballots, :Ballot

  def self.fetch(identifier)
    with(:email, identifier) || with(:username, identifier)
  end

  def before_delete
    # The following loop needs to be changed, to not iterate through ALL the groups
    Group.all.each do |group|
      group.voters.delete(self)
    end

    ballots.each do |ballot|
      if ballot.voters.size == 1
        ballot.delete
      else
        ballot.voters.delete(self)
      end
    end

    groups.each(&:delete)

    super
  end
end
