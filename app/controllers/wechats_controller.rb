class WechatsController < ApplicationController
  include Sutils::Schoolbus
  include Sutils::Qrcode
  wechat_responder

  # activity => carteen
  on :text, with: /抽奖/ do |request|

    user = User.find_by(open_id: request[:FromUserName])
    unless user
      user = User.new
      user.open_id = request[:FromUserName]
      user.save
    end

    degist = base64encode(user.open_id)
    if CanteenDegist.find_by(degist: degist) 
      request.reply.text "已经兑换过了！"
    else
      filename = base64qr(user.open_id)
      r = Wechat.api.media_create "image", filename
      # TODO: add hint / 
      request.reply.image r['media_id']
    end

  end

  on :click, with: 'CANTEEN' do |request|
  end

  # response

  on :text, with: /校车/ do |request|
    request.reply.text next_bus
  end

  # default response
  on :text do |request|
    request.reply.text '我们收到您的留言啦。说不定一会儿小编就会联系您哒~
    
北京航空航天大学学生会竭诚为你服务 /:heart'
  end

  on :event, with: 'subscribe' do |request|
    request.reply.text '感谢您关注“北京航空航天大学学生会”微信平台/:rose！
    
点击下方“校&汇”浏览校园生活信息。实用功能栏查询校车校历。
    
北京航空航天大学学生会竭诚为您服务/:heart'
  end

  # menu response
  on :click, with: 'SCHOOLBUS' do |request|
    request.reply.text '功能正在开发中..'
  end

  on :click, with: 'FEEDBACK' do |request|
    request.reply.text '发送 吐槽 + 您的意见'
  end

  on :click, with: 'CALENDER' do |request|
    request.reply.image 'NjRvKRIAWWC3esDN3eGYw21MvKzGBtDRKLMflOX2jeE'
  end

end
