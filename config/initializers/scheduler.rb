require 'rufus-scheduler'

if (
  ! defined?(Rails::Console) &&
  File.basename($0) != 'rake'
) then

  scheduler = Rufus::Scheduler.new

  scheduler.every '2h' do
    Rails.logger.info "[#{Time.now}] Start fetching facebook posts"
    FileUtils.rm_rf("#{ENV['PLAYQPID_WEB_POST_FOLDER_PATH']}/.", secure: true)
    FB.generate_web_post_from_page_post
    FileUtils.cp_r("#{ENV['PLAYQPID_WEB_POST_FOLDER_PATH']}/.", "#{ENV['PLAYQPID_POST_FOLDER_PATH']}/")
    cmd = <<~EOF
      cd #{ENV['PLAYQPID_FOLDER_PATH']}
      git add .
      git commit -m "Add posts"
      git push heroku master
    EOF
    `#{cmd}`

    FileUtils.rm_rf("#{ENV['PLAYQPID_WEB_POST_FOLDER_PATH']}/.", secure: true)
    Rails.logger.info "[#{Time.now}] Finished"
  end

  scheduler.in '1s' do
    Rails.logger.info "[#{Time.now}] Scheduler has started"
  end

  scheduler.every '15s' do
    Rails.logger.info "[#{Time.now}] Scheduler is still running"
  end

  scheduler.join
end
