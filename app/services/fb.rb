class FB
  def self.client
    @@client ||= Koala::Facebook::API.new(Koala.config.access_token)
  end

  def self.generate_web_post_from_page_post
    posts = FB.client.get_connections(ENV['FB_PAGE_ID'], 'posts')
    loop do
      posts.each do |post|
        next unless post["message"].present? && post["message"].match(/#goplayqpid/)
        attachments = FB.client.get_connections(post["id"], 'attachments')

        web_post = WebPostGenerator.new(
          id: post["id"], 
          content: post["message"], 
          photos: get_photos(attachments)
        )
        web_post.build
        web_post.save
        raise
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
end
