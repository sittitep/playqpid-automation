require 'rufus-scheduler'

if (
  ! defined?(Rails::Console) &&
  File.basename($0) != 'rake'
) then

  scheduler = Rufus::Scheduler.new

  scheduler.every '2h' do
    # Delete all prev posts
    FileUtils.rm_rf("#{Rails.root.join('web_posts')}/.", secure: true)
    # Generate new posts
    FB.generate_web_post_from_page_post
    # Move new posts to web
    FileUtils.cp_r("#{Rails.root.join('web_posts')}/.", "#{ENV['PLAYQPID_POST_FOLDER_PATH']}/")
    cmd = <<~EOF
      cd #{ENV['PLAYQPID_FOLDER_PATH']}
      git add .
      git commit -m "Add posts"
      git push heroku master
    EOF
    `#{cmd}`

    FileUtils.rm_rf("#{Rails.root.join('web_posts')}/.", secure: true)
  end

  scheduler.join
end
