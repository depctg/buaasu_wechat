class User < ApplicationRecord
  has_one :sign_record, autosave: true, dependent: :delete
  has_many :treehole_messages
  has_many :degists
  mount_uploader :avatar, AvatarUploader
  # user.remote_avatar_url
  
  def User.from_request(request)
    user = User.find_by(open_id: request[:FromUserName])
    if user.nil?
      # create User here
      user_info = Wechat.api.user(request[:FromUserName])
      user = User.new
      user.open_id = request[:FromUserName]
      user.remote_avatar_url = user_info['headimgurl']
      user.nickname = user_info['nickname']
      user.save
    elsif user.avatar.file.nil? || user.nickname.nil?
      user_info = Wechat.api.user(request[:FromUserName])
      user.remote_avatar_url = user_info['headimgurl']
      user.nickname = user_info['nickname']
      user.save
    end
    return user
  end
end
