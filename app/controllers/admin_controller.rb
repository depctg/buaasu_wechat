class AdminController < ApplicationController
  http_basic_authenticate_with name: "buaasu", password: "ilovegmbuaa"

  def gmbuaa
    @images = Dir.glob(File.join('public', 'uploads', 'gmtemplates', '*.jpg'))
    # Rails will auto server files in public folder
    @images.map! { |img| '/' + img.split('/')[1..-1].join('/') }
    @images = @images.group_by {|f| f.split('_')[0].split('/').last}
    @images = @images.sort.to_h
    # get data for static datas
  end

  def gmupload
    uploader = GmtemplateUploader.new
    uploader.store! params[:gmupload][:image]
    # upload image files
    redirect_to :admin_gmbuaa
  end

  def gmdelete

    filename = File.join('public', 'uploads', 'gmtemplates', params[:filename] + '.jpg')
    File.delete(filename)
    # upload image files
    redirect_to :admin_gmbuaa
  end
end
