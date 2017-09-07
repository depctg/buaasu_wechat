class WechatsController < ApplicationController
  include Sutils::Schoolbus
  include Sutils::Qrcode
  include Sutils::WechatHelper
  include Sutils::Signin
  wechat_responder

  # constants, access keys
  IMG_CALENDER = 'NjRvKRIAWWC3esDN3eGYwy5pEqeli7QJ6kQQmKZtjUY'
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
  on :text, with: /迎新福利/ do |request|
    request.reply.text 'https://www.sojump.hk/jq/15672123.aspx'
  end
  on :text, with: /摄影大赛 (\S+) (\d+) (\d+)/ do |request, name, school_id, number|
    user = User.from_request request
    degist_param = {subject: 'PHOTOCON', degist_class: 'INFO', content: name + ' ' + school_id + ' ' + number}
    if user.degists.exists? degist_param
      request.reply.text "已经收到你的联系方式，工作人员会在近期联系你❤️"
    else
      user.degists.create degist_param
      request.reply.text "已经收到你的联系方式，工作人员会在近期联系你❤️"
    end
  end

  on :text, with: /我想拥抱你/ do |request|
    pic = [
      'a_m15nS83WsRrCe0awSChEamlOYSSTSsTFzo_5D35qSsWvYs8285y5A0TE75jlty',
      'IWMiCLaisIHiYliZ2ZIiZEQspVtFYwn7VhixVUJ044Ot1jfSpxy_2Jp0NzJeoGwK',
      'Y_OyNPe6Uo3Q-MauAPpGrm0WkDl6ac5rh75Q0m5odkUPGdWE5WEtakd7kDvd6r5P',
      'xDZb_L-UfNKKgdj8jvrWDTzQMddO7ctlIUOsW5oc5BzBeZZ4Cndj5phRQLy9pLi8',
      'MMZABwdhX2DyQ3IzHJUKH0nuc1p5pkBjsFhJ9W8b0gI13G1lI8RPrIxANF6m8rQd',
      '35lz3wGA-56X2_lUarP0aCebHN0K_PEW6mNZ1Fa8yiWy2AwANjbjhHMjpyrMVuBp',
      'OZYCd8TacE8Ro8r6wew7K_-1AN4jnQFsopn6Qslu0F4IYDFfm_zS17_LNV-_ODW3' ]

    request.reply.text ''
    user = User.from_request request
    degist_param = {subject: 'LOCK', degist_class: '214IMG'}

    unless user.degists.exists? degist_param
      user.degists.create degist_param
      pic.each do |p|
        msg = {
          touser: request[:FromUserName],
          msgtype: "image",
          image:
          {
            media_id: p
          }
        }
        Wechat.api.custom_message_send msg
      end
      sleep 10
    end

  end

  # activity
  on :text, with: /鸡年大吉/ do |request|
    request.reply.text '链接https://pan.baidu.com/s/1eRVp4BK'
  end

  # Tests

  on :text, with: /(早安|早上好)/ do |request|

    # Mutex for multi requests

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
      end_t = "#{now_date} 09:00:00 +0800".to_time
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
          user_msg = "早安~ 今天已经签过到了呦～"
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
        user_msg = "早安~ 已经过了签到时间了哦~ 试试明天早起吧！"
      end

      # gen picture here
      if user_status

        user.sign_record.lock = true
        user.save

        templates = Dir.glob(File.join('public', 'uploads', 'gmtemplates', '*.jpg'))
        templates.select! {|f| f.include?(now_date)}
        media_id = temp_image(gen_picture(user, template: templates.sample))
        msg_text = {
          touser: request[:FromUserName],
          msgtype: "text",
          text:
          {
            content: '早安~'
          }
        }
        msg = {
          touser: request[:FromUserName],
          msgtype: "image",
          image:
          {
            media_id: media_id
          }
        }
        Wechat.api.custom_message_send msg_text
        Wechat.api.custom_message_send msg

        # Welcome message
        if user.sign_record.days.size == 1

          msg_text = {
            touser: request[:FromUserName],
            msgtype: "text",
            text:
            {
              content: '邀请你的小伙伴来和我们一起“早安，北航”吧！给小伙伴晒出你的早起天数，精神满满地开启每一天！坚持签到更有神秘奖品拿哦！'
            }
          }

          Wechat.api.custom_message_send msg_text

        end

        if [15,16].include? user.sign_record.day
          msg_text = {
            touser: request[:FromUserName],
            msgtype: "text",
            text:
            {
              content: '恭喜你完成本期“早安，北航”的签到任务！撒花~
记得活动结束后按照公众号消息你领取你的“早安，北航”纪念明信片哦~'
            }
          }
          Wechat.api.custom_message_send msg_text
        end

        sleep 10

        user.sign_record.lock = false
        user.save
      else
        request.reply.text user_msg unless user.sign_record.lock
      end

  end

  on :text, with: /^(学霸|文青|吃货|单身|情侣|闺蜜|基友)卡/ do |request, card_type|
    degist_param = case card_type
        when '学霸' then {subject: 'LILIC_CARD', degist_class: 'XUEBA'}
        when '文青' then {subject: 'LILIC_CARD', degist_class: 'WENQING'}
        when '吃货' then {subject: 'LILIC_CARD', degist_class: 'CHIHUO'}
        when '单身' then {subject: 'LILIC_CARD', degist_class: 'DANSHEN'}
        when '情侣' then {subject: 'LILIC_CARD', degist_class: 'QINGLV'}
        when '闺蜜' then {subject: 'LILIC_CARD', degist_class: 'GUIMI'}
        when '基友' then {subject: 'LILIC_CARD', degist_class: 'JIYOU'}
        else nil
      end

    unless degist_param.nil?
      if Degist.count_by('LILIC_CARD', degist_class: degist_param[:degist_class]) < 20
        user = User.from_request request
        if user.degists.exists? degist_param
          request.reply.text "你已经有一张#{card_type}卡了！"
        else
          user.degists.create degist_param
          request.reply.text "恭喜你抢到了一张#{card_type}卡！"
        end
      else
        request.reply.text '真可惜，卡已经被抢完了...'
      end
    else
      request.reply.text '这里好像没有这样的卡片...'
    end
  end

  on :text, with: /^查询(学霸|文青|吃货|单身|情侣|闺蜜|基友)卡/ do |request, card_type|
    degist_param = case card_type
        when '学霸' then {subject: 'LILIC_CARD', degist_class: 'XUEBA'}
        when '文青' then {subject: 'LILIC_CARD', degist_class: 'WENQING'}
        when '吃货' then {subject: 'LILIC_CARD', degist_class: 'CHIHUO'}
        when '单身' then {subject: 'LILIC_CARD', degist_class: 'DANSHEN'}
        when '情侣' then {subject: 'LILIC_CARD', degist_class: 'QINGLV'}
        when '闺蜜' then {subject: 'LILIC_CARD', degist_class: 'GUIMI'}
        when '基友' then {subject: 'LILIC_CARD', degist_class: 'JIYOU'}
        else nil
      end

    unless degist_param.nil?
      cards = Degist.where(degist_param)
      if cards.nil?
        request.reply.text '这里好像没有这样的卡片...'
      else
        res = cards.map {|c| c.user.nickname}
        request.reply.text res.to_s
      end
    else
      request.reply.text '这里好像没有这样的卡片...'
    end
  end

  on :text, with: /晚会/ do |request|
    user = User.from_request request
    degist_param = {subject: 'LILIC', degist_class: 'TICKET'}
    if user.degists.exists? degist_param
      request.reply.text "您已经领到票了！"
    else
      user.degists.create degist_param
      request.reply.text "报名成功，请于12月3日晚18:30准时到咏曼剧场参加晚会~"
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

  on :text, with: /^树洞 (.*)/ do |request, msg|

    user = User.find_by(open_id: request[:FromUserName])
    if user.nil?
      user = User.new
      user.open_id = request[:FromUserName]
    end

    status, reply = Treehole.add_message user, msg.strip
    if status
      request.reply.text "树洞里传来了回声：“#{reply}”"
    else
      request.reply.text reply
    end
  end

  on :text, with: /音乐节/ do |request|
    request.reply.text '您已成功获得领取一张外场抽奖券的机会。'
  end

  # images
  # on :image do |request|

    # user = User.find_by(open_id: request[:FromUserName])

    # if user.nil?
      # # create User here
      # user = User.new
      # user.open_id = request[:FromUserName]
      # user.nickname = Wechat.api.user(request[:FromUserName])['nickname']
    # elsif user.nickname.nil?
      # user.nickname = Wechat.api.user(request[:FromUserName])['nickname']
    # end

    # user.save

    # path = File.join('public', 'uploads', 'image_messages')
    # Wechat.api.media request[:MediaId], path # Save Image to path


    # request.reply.text '感谢您投稿醉美北航!'
  # end

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
