class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
          :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    data = auth.info
    user = User.where(email: data["email"]).first

    unless user
        user = User.create(name: data["name"],
           email: data["email"],
           avatar_url: data["image"],
           provider: auth["provider"],
           uid: auth["uid"],
           password: Devise.friendly_token[0,20]
        )
    end

    if user.persisted?
      user.access_token = auth.credentials.token
      user.expires_at = auth.credentials.expires_at
      user.refresh_token = auth.credentials.refresh_token
      user.save!
    end

    user
  end
end
