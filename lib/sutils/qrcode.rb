module Sutils::Qrcode
  USE_URL = "http://su.depct.cn/canteen/" 
  def base64qr(idf)
    filename = "/tmp/#{idf}-qrcode.png"
    degist = base64encode(idf)
    qrcode = RQRCode::QRCode.new(USE_URL + "#{degist}")
    qrcode.as_png(
      file: filename, border_modules: 1
    )
    return filename
  end

  def qr(content)
    filename = "/tmp/#{content}-qrcode.png"
    qrcode = RQRCode::QRCode.new(content)
    qrcode.as_png(
      file: filename, border_modules: 1
    )
    return filename
  end

  def base64encode(idf)
    Base64.encode64(idf)[0...-1]
  end

  def add_background(qr_file, bg_file, size, x, y, option = {})

    bg = MiniMagick::Image.open(bg_file)
    qr = MiniMagick::Image.open(qr_file)

    qr.resize "#{size}x#{size}"
    res = bg.composite(qr, "png") do |c|
      c.compose  "Over"
      c.geometry "+#{x}+#{y}"
    end

    res.write qr_file

    return qr_file

  end

end

