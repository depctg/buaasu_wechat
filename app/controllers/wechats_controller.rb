class WechatsController < ApplicationController
  include Sutils::Schoolbus
  include Sutils::Qrcode
  include Sutils::WechatHelper
  include Sutils::Signin
  wechat_responder

  # constants, access keys
  IMG_CALENDER = 'NjRvKRIAWWC3esDN3eGYw21MvKzGBtDRKLMflOX2jeE'
  IMG_SCHOOLBUS = 'NjRvKRIAWWC3esDN3eGYw5V3nM0uvncD1yfGTO6tUwE'

  # activity => carteen

  on :text, with: '查看优惠券' do |request|
    degist = CanteenDegist.find_by(degist: base64encode(request[:FromUserName])) 
    if degist
      if degist.is_picked 
        if not degist.is_used
          filename = qr(degist.degist)
          filename = add_background(filename, 'lib/assets/image/canteen_bg.jpeg', 405, 26, 149)
          request.reply.image temp_image(filename)
        else
          request.reply.text "您的优惠券已经使用过了！"
        end
      else
        request.reply.text "您已经抽过了，但并没有中奖！"
      end
    else
      request.reply.text "您还没有抽奖！"
    end
  end

  # response

  on :text, with: /校车/ do |request|
    request.reply.image IMG_SCHOOLBUS
  end

  # Tests
  on :text, with: /测试签到/ do |request|

    user = User.find_by(open_id: request[:FromUserName])
    if user.nil?
      # create User here
      user = User.new
      user.open_id = request[:FromUserName]
      user.remote_avatar_url = Wechat.api.user(request[:FromUserName])['headimgurl']
    elsif user.avatar.file.nil?
      user.remote_avatar_url = Wechat.api.user(request[:FromUserName])['headimgurl']
    end

    if user.sign_record.nil?
      user.sign_record = SignRecord.new
      user.sign_record.days = []
      user.sign_record.day = 0
    end

    # if is valid
    user_status = false
    user_msg = nil

    now_t = Time.now
    now_date = now_t.strftime('%Y-%m-%d')
    # hardcode this
    start_t = "#{now_date} 05:00:00 +0800".to_time
    end_t = "#{now_date} 20:00:00 +0800".to_time
    if start_t <= now_t && now_t < end_t
      lastdate = (Time.now - 24.hours).strftime('%Y-%m-%d')
      if not user.sign_record.last_sign_time
        user_status = true
        user.sign_record.days ||= []
        user.sign_record.days << now_t
        user.sign_record.day = 1
        user.sign_record.last_sign_time = now_t
      elsif user.sign_record.last_sign_time > "#{now_date} 00:00:00 +0800".to_time
        user_status = false
        user_msg = "您今天已经签过到了"
      elsif user.sign_record.last_sign_time < "#{lastdate} 00:00:00 +0800".to_time
        user_status = true
        user.sign_record.days << Time.now
        user.sign_record.day = 1
        user.sign_record.last_sign_time = now_t
      else
        user_status = true
        user.sign_record.last_sign_time = now_t
        user.sign_record.days << Time.now
        user.sign_record.day += 1
      end
    else
      user_status = false
      user_msg = "现在不在签到时间。"
    end

    user.save

    # gen picture here
    if user_status
      # templates = Dir.glob(File.join('public', 'uploads', 'gmtemplates', '*.jpg'))
      # templates.select! {|f| f.include?(now_date)}
      # request.reply.image temp_image(gen_picture(user, template: templates.sample))
      request.reply.image temp_image(gen_picture(user, template: 'public/uploads/gmtemplates/2016-10-18_0.jpg'))
    else
      request.reply.text user_msg
    end

  end

  on :text, with: /签到注册/ do |request|

    user = User.find_by(open_id: request[:FromUserName])
    if user.nil?
      # create User here
      user = User.new
      user.open_id = request[:FromUserName]
      user.remote_avatar_url = Wechat.api.user(request[:FromUserName])['headimgurl']
    elsif user.avatar.file.nil?
      user.remote_avatar_url = Wechat.api.user(request[:FromUserName])['headimgurl']
    end

    if user.sign_record.nil?
      user.sign_record = SignRecord.new
      user.sign_record.days = []
      user.sign_record.day = 0

      user.save
    else
      request.reply.text "已经注册过了!"
    end

  end

  # default response
  on :text do |request|
    request.reply.text '我们收到您的留言啦。说不定一会儿小编就会联系您哒~
    
北京航空航天大学学生会竭诚为你服务 /:heart'
  end

  on :event, with: 'subscribe' do |request|
    request.reply.text '感谢您关注“北京航空航天大学学生会”微信平台/:rose！
    
点击下方“校&汇”浏览校园生活信息。实用功能栏查询校车校历。
    
北京航空航天大学学生会竭诚为您服务 /:heart'
  end

  # menu response
  on :click, with: 'SCHOOLBUS' do |request|
    request.reply.image IMG_SCHOOLBUS
  end

  on :click, with: 'FEEDBACK' do |request|
    request.reply.text '发送 吐槽 + 您的意见'
  end

  on :click, with: 'CALENDER' do |request|
    request.reply.image IMG_CALENDER
  end

end
