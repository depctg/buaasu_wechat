class User < ApplicationRecord
  has_one :sign_record 
  mount_uploader :avatar, AvatarUploader
  # user.remote_avatar_url
end
