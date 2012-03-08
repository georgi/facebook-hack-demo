# Users should be saved in a database. This is just plain ruby object
# for demonstration purpose.
class User
  attr_reader :uid, :name, :token

  def self.all
    @all ||= []
  end

  def self.find_by_uid(uid)
    all.find {|user| user.uid == uid }
  end

  # Find a user by facebook user id or create a new one
  # given the information fetched from Facebook.
  def self.from_facebook(facebook)
    user = find_by_uid(facebook.me['id'])

    if user.nil?
      user = User.new
      User.all << user
    end

    user.from_facebook(facebook)
    user
  end

  # Initialize attributes from Facebook client
  def from_facebook(facebook)
    @facebook = facebook
    @token = facebook.token
    @name = facebook.me['name']
    @uid = facebook.me['id']
  end

  def facebook
    @facebook ||= Facebook.new(token)
  end
end
