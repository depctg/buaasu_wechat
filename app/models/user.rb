class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  # user.remote_avatar_url
end
