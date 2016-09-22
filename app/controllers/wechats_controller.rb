class WechatsController < ApplicationController
  include Sutils::Schoolbus
  wechat_responder

  on :text, with: /校车/ do |request|
    request.reply.text next_bus
  end

  # default response
  on :text do |request|
    request.reply.text '您好，您的留言我们收到啦！别着急，说不定一会儿就会有小编回复您的哦！'
  end

  on :event, with: 'subscribe' do |request|
    request.reply.text "感谢您关注北京航空航天大学学生会！"
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
