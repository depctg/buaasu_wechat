class User < ApplicationRecord
  has_one :sign_record, autosave: true, dependent: :delete
  mount_uploader :avatar, AvatarUploader
  # user.remote_avatar_url
end
