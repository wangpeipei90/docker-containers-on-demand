class User
  include Mongoid::Document
  has_and_belongs_to_many :groups
  has_many :group_applications

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  field :name,               type: String, default: ""

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  def is_leader group
    group.leader == self
  end

  def is_member group
    group.users.include? self
  end

  def is_pending_applicant? group
    self.group_applications.each do |ga|
      return true if ga.group == group && ga.status.to_sym == :pending
    end
    false
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # user created if they don't exist
    unless user
      user = User.create(name: data["name"],
        email: data[:email],
        password: Devise.friendly_token[0,20],
        name: data[:name]
      )
    end
    user
  end

  # def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
  #   data = access_token.info
  #   user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
  #   if user
  #     return user
  #   else
  #     registered_user = User.where(:email => access_token.info.email).first
  #     if registered_user
  #       return registered_user
  #     else
  #       user = User.create(name: data["name"],
  #           provider: access_token.provider,
  #           email: data["email"],
  #           uid: access_token.uid ,
  #           password: Devise.friendly_token[0,20]
  #       )
  #     end
  #   end
  # end
end
