class WechatsController < ApplicationController
  include Sutils::Schoolbus
  include Sutils::Qrcode
  include Sutils::WechatHelper
  wechat_responder

  # constants, access keys
  IMG_CALENDER = 'NjRvKRIAWWC3esDN3eGYw21MvKzGBtDRKLMflOX2jeE'

  # activity => carteen
  on :text, with: /抽奖/ do |request|

    user = User.find_by(open_id: request[:FromUserName])
    unless user
      user = User.new
      user.open_id = request[:FromUserName]
      user.save
    end

    degist_str = base64encode(user.open_id)
    degist = CanteenDegist.find_by(degist: degist_str) 
    if degist
      if degist.is_picked
        if degist.is_used
          request.reply.text "您已经兑换过了！"
        else
          request.reply.text "您已经领取，请到食堂三楼北水吧处兑换！回复 查看优惠券 查看您的优惠券。"
        end
      else
        request.reply.text "您已经抽过了，但并没有中奖！"
      end
    else
      total_ticket = CanteenDegist.where(is_picked: true).count

      if (total_ticket >= 2000)
        request.reply.text "优惠券已经被抽完了！"
      else
        # 33% to get a ticket
        if [false, false, true].sample
          CanteenDegist.create(degist: degist_str, is_picked: true) 
          filename = base64qr(user.open_id)
          filename = add_background(filename, 'lib/assets/image/canteen_bg.jpeg', 405, 26, 149)
          request.reply.image temp_image(filename)
        else
          CanteenDegist.create(degist: degist_str, is_picked: false)
          request.reply.image "NjRvKRIAWWC3esDN3eGYw15W1xbymgUJNJtuGZ4aWMs"
        end
      end
    end

  end

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

  on :click, with: 'CANTEEN' do |request|
    degist = CanteenDegist.find_by(degist: base64encode(request[:FromUserName])) 
    if degist
      if degist.is_picked 
        if not degist.is_used
          request.reply.text "您已经领取，请到食堂三楼北水吧处兑换！回复 查看优惠券 查看您的优惠券。"
        else
          request.reply.text "您的优惠券已经使用过了！"
        end
      else
        request.reply.text "您已经抽过了，但并没有中奖！"
      end
    else
      total_ticket = CanteenDegist.where(is_picked: true).count

      if (total_ticket >= 2000)
        request.reply.text "优惠券已经被抽完了！"
      end
      # 33% to get a ticket
      if [false, false, true].sample
        CanteenDegist.create(degist: base64encode(request[:FromUserName]), is_picked: true) 
        filename = base64qr(request[:FromUserName])
        filename = add_background(filename, 'lib/assets/image/canteen_bg.jpeg', 405, 26, 149)
        request.reply.image temp_image(filename)
      else
        CanteenDegist.create(degist: base64encode(request[:FromUserName]), is_picked: false)
        request.reply.image "NjRvKRIAWWC3esDN3eGYw15W1xbymgUJNJtuGZ4aWMs"
      end
    end
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
    
北京航空航天大学学生会竭诚为您服务 /:heart'
  end

  # menu response
  on :click, with: 'SCHOOLBUS' do |request|
    request.reply.text '功能正在开发中..'
  end

  on :click, with: 'FEEDBACK' do |request|
    request.reply.text '发送 吐槽 + 您的意见'
  end

  on :click, with: 'CALENDER' do |request|
    request.reply.image IMG_CALENDER
  end

end
