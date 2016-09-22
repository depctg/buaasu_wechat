namespace :wechat do
  desc 'Update menu config'
  task :menu do
    menu = YAML.load(File.read("#{Rails.root}/config/wechat_menu.yaml"))
    Wechat::ApiLoader.with({}).menu_create menu
    p "Wechat menu updated"
  end
end
