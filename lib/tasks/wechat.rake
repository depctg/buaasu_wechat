namespace :wechat do
  desc 'Update menu config'
  task :menu do |args|
    menu = YAML.load(File.read("#{Rails.root}/config/wechat_menu.yaml"))
    Wechat::ApiLoader.with({}).menu_create menu
    p "Wechat menu updated"
  end

  desc 'upload an image'
  task :image, :filename do |t, args|
    r = Wechat.api.material_add("image", args[:filename])
    if r['media_id']
      Clipboard.copy(r['media_id'])
      p 'Upload success! Media id copied to Clipboard'
      p r['media_id']
    else
      p 'Upload failed.'
    end
    
  end
end
