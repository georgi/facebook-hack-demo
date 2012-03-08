require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :user => 'root',
  :database => 'mobile-hack')

class UserMigration < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :token
      t.string :name
      t.string :uid
    end
  end

  def self.down
    drop_table :users
  end
end

class User < ActiveRecord::Base

  def self.from_facebook(facebook)
    user = find_by_uid(facebook.uid) || new
    user.from_facebook(facebook)
    user.save!
    user
  end

  def from_facebook(facebook)
    self.attributes = {
      :token => facebook.token,
      :name => facebook.name,
      :uid => facebook.uid
    }
  end
end

UserMigration.up unless User.table_exists?
