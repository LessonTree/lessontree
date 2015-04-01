class User < ActiveRecord::Base

  acts_as_commontator

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  has_many :lessons
  has_many :grade_levels, through: :lessons
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         :omniauth_providers => [:facebook]

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb =>
      "100x100>" }, :default_url => "http://goo.gl/n8UsdL"
  validates_with AttachmentSizeValidator, :attributes => :avatar,
      :less_than => 3.megabytes
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  # validates_presence_of :name

  def to_s
    name
  end

  def self.find_version_author(version)
    find(version.terminator)
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name:auth.extra.raw_info.name,
                            provider:auth.provider,
                            uid:auth.uid,
                            email:auth.info.email,
                            password:Devise.friendly_token[0,20],
                          )
      end
    end
  end
end
