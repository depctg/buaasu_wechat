module Sutils::WechatHelper
  # put head in tmp
  # for foller module
  def access_id
    # varify key
    p test
  end

  def temp_image(file)
    r = Wechat.api.media_create "image", file
    return r['media_id']
  end
end
