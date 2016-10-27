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

  on :text, with: /摄影大赛/ do |request|
    request.reply.text '    ● 投稿方式
    buaa2016syds@163.com
    ● 投稿时间
    2016年10月25日——2015年11月13日
    ● 作品要求
    1) 本次摄影大赛上交作品不限制拍摄时间，但内容必须包含北航元素。
    2) 每幅照片不小于1MB，格式为JPEG或JPG。
    3) 参赛者可以使用PS等修图软件处理图片（仅限轻微修图，如裁剪，提高亮度等），但不可以虚构元素，影响作品真实性，一经发现立即取消参赛资格。
    4) 本次大赛趣味组的摄影对象为北航的动物，参加趣味组摄影的作品必须以北航的动物为主体进行摄影，动物包括但不限于猫、狗、鸟、昆虫等。
    5) 照片必须为本人亲自拍摄，不得盗图、抄袭他人作品，一经发现取消参赛资格，且本次比赛只接受电子档作品。
    ● 投稿说明
    1) 本次大赛设置手机组、相机组和趣味组，手机组与相机组投稿数量每人最多可以投稿三张，趣味组每人仅限一张 。手机组和相机组投稿超过三张的，按时间先后取后三张；趣味组投稿超过一张的，以最后一张投稿为准。
    2) 参赛者需要将自己上交的作品（或作品包）统一命名为“摄影大赛+参与组别+拍摄地点及拍摄内容+姓名+学号+联系方式”
    例如：
    摄影大赛+相机组+大钟广场夜景+张三+12341234+13012341234
    摄影大赛+手机组+居民楼老教授+张三+12341234+13012341234
    摄影大赛+趣味组+猫+张三+12341234+13012341234
    不注明拍摄地点或拍摄内容的投稿视为无效投稿。投稿支持压缩上传和原图上传，但获奖作品未上传原图的，主办方将在之后要求作者上传原图。
    3) 参赛者也需要将邮件主题采用上述“摄影大赛+参与组别+拍摄地点及拍摄内容+姓名+学号+联系方式”的方式命名。'
  end

  # Tests
  on :text, with: /九宫格/ do |request|
    request.reply.text '真遗憾，没有抽中。别灰心，只要你将“九宫格”推送转发到朋友圈，到店消费时出示给店员即可享受满200立减30的优惠！'
  end

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


        sleep 10

        user.sign_record.lock = false
        user.save
      else
        request.reply.text user_msg unless user.sign_record.lock
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
