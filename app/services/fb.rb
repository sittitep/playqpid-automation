class FB
  def self.client
    @@client ||= Koala::Facebook::API.new(Koala.config.access_token)
  end

  def self.connect_url
    puts "Get user access token from he link below"
    puts oauth.url_for_oauth_code(permissions: "manage_pages,publish_pages")
  end

  def self.get_access_token(code)
    puts oauth.get_access_token(code)
  end

  def self.generate_web_post_from_page_post
    posts = FB.client.get_connections(ENV['FB_PAGE_ID'], 'posts')
    loop do
      posts.each do |post|
        next if post["message"].blank? || !post["message"].match(/#goplayqpid/) || post["message"].match(/www.playqpid.com/)
        attachments = FB.client.get_connections(post["id"], 'attachments')

        web_post = WebPostGenerator.new(
          id: post["id"], 
          content: post["message"], 
          photos: get_photos(attachments),
          created_at: post["created_time"]
        )
        web_post.build
        web_post.save
        attach_web_post_to_page_post(web_post.id, post["message"] + "\n\n[ #{web_post.web_post_path} ]")
      end
      next_posts = posts.next_page
      if next_posts.present?
        posts = next_posts
      else
        break
      end
    end
  end

  def self.get_photos(attachments)
    attachments[0].dig("subattachments","data").map{|data| data.dig("media","image","src")}
  end

  def self.oauth
    callback_url = "https://www.playqpid.com/"
    @@oauth ||= Koala::Facebook::OAuth.new(Koala.config.app_id, Koala.config.app_secret, callback_url)
  end

  def self.page_client
    @@page_client ||= Koala::Facebook::API.new(ENV["FB_PAGE_ACCESS_TOKEN"])
  end

  def self.attach_web_post_to_page_post(id, message)
    page_client.put_object(id, "", message: message)
  end
end
