class WebPostGenerator
  attr_accessor :id, :post_id, :photos, :web_post, :section_hash, :web_post_path

  def initialize(args)
    @id = args[:id]
    @post_id = @id.split("_").last
    @photos = args[:photos]
    @sections = args[:content].gsub("\n","").split("...")
    @section_hash = {
      title: @sections[0],
      description: @sections[1],
      body: @sections[2],
      tag: @sections[3],
      reference: @sections[4]
    }
    @web_post_path = "https://www.playqpid.com/" + Date.today.strftime.gsub("-","/") + "/#{self.post_id}.html"
  end

  def build
    self.web_post = <<~HEREDOC
      ---
      layout: post
      fb_post_id: #{id}
      title: #{section_hash[:title]}
      description: #{section_hash[:description]}
      image: #{photos[0]}
      photos: #{photos}
      writter:
        name: แม่สื่อแม่ชัก
        picture: https://scontent.fbkk14-1.fna.fbcdn.net/v/t1.0-9/19905468_257990828018680_1300189550768818950_n.jpg?_nc_cat=0&_nc_eui2=AeEZYdQgaOxgXIKmVEoEITEVBssDPkrxbmLUT6aK5DSeA8Y-1PYGOZTFL0FWfIR0hQ5cHihf4g7Ra5vQGBfYiPRSpt5ItSofRQ7xR_A0K2VyyQ&oh=d4afec3688711fd3918544327ed0196f&oe=5B8BFCF9
      source: https://www.facebook.com/playQpid/posts/#{@post_id}
      ---
      #{section_hash[:body]}

      #{section_hash[:tag]}

      #{section_hash[:reference]}
    HEREDOC
  end

  def save
    title = [
      Date.today.strftime,
      self.post_id
    ].join("-")

    File.open("web_posts/#{title}.markdown", "w+") do |f|
      f.write(self.web_post)
    end
  end
end
