class User < ApplicationRecord
  has_one :sign_record, autosave: true, dependent: :delete
  has_many :treehole_messages
  mount_uploader :avatar, AvatarUploader
  # user.remote_avatar_url
end
