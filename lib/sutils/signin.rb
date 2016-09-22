module Sutils::Signin

  def gen_picture(signrecord, options={})

    def gen_filename
      "/var/tmp/#{signrecord.id}_#{Time.now.day}.jpg"
    end

    # default options
    options[:head_position] ||= '+30+60'
    options[:head_size] ||= '160x160'
    options[:mask] ||= "#{Rails.root}/lib/sutils/img/mask.jpg"
    options[:time_position] ||= '220,220'
    options[:day_position] ||= '455,220'
    options[:font] ||= "#{Rails.root}/lib/sutils/font/AdobeHeitiStd-Regular.otf"
    options[:number_size] ||= 70
    options[:template] ||= "template_#{Time.now.strftime('%D')}.jpg"

    img_head = MiniMagick::Image.open(signrecord.avatar)
    img_template = MiniMagick::Image.open(options[:template])
    img_mask = MiniMagick::Image.open(options[:mask]) 
    # img_template.pa
    img_head.resize options[:head_size]
    img_template =
      img_template.composite(img_head, "jpg", img_mask) do |c|
        c.compose  "Over"
        c.geometry options[:head_position]
    end

    img_template.combine_options do |i|
      i.font options[:font]
      i.pointsize options[:number_size]
      i.fill 'white'
      i.draw "text #{options[:time_position]} \"#{Time.now.strftime("%H:%M")}\""
      i.draw "text #{options[:day_position]} \"#{signrecord.day}\""
    end

    result = gen_filename
    img_template.write result
    result
  end

end
