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

  def base64encode(idf)
    Base64.encode64(idf)[0...-1]
  end
end

