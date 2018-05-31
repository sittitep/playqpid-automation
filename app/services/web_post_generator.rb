class WebPostGenerator
  attr_accessor :id, :photos, :web_post, :section_hash

  def initialize(args)
    @id = args[:id]
    @photos = args[:photos]
    @sections = args[:content].gsub("\n","").split("...")
    @section_hash = {
      title: @sections[0],
      intro: @sections[1],
      body: @sections[2],
      reference: @sections[3],
      tag: @sections[4]
    }
  end

  def build
    self.web_post = <<~HEREDOC
      ---
      layout: post
      fb_post_id: #{id}
      title: #{section_hash[:title]}
      intro: #{section_hash[:intro]}
      thumbnail: #{photos[0]}
      photos: #{photos}
      writter:
        name: Arthida Ker Aer Tosuwan
        picture: https://scontent.fbkk14-1.fna.fbcdn.net/v/t1.0-9/31902116_10160333309455026_6113134047406325760_n.jpg?_nc_cat=0&_nc_eui2=AeECu39etPWJiqSCFp0tplOYZNcD3xiEgcYpk6tgOjTxc_JVinyndrO0XBUbjA39DsgrJqNNBNb-T__9WWUiCDlvIHjrb1Kbk5N5HnLYKMnCcg&oh=dfa71c880cad335e16a99dd53ae9d6cd&oe=5B767EE2
      ---
      #{section_hash[:body]}

      #{section_hash[:reference]}

      #{section_hash[:tag]}
    HEREDOC
  end

  def save
    title = [
      Date.today.strftime, 
      self.section_hash[:title].gsub(" ","-"), 
      self.id.split("_").last
    ].join("-")

    File.open("web_posts/#{title}.markdown", "w+") do |f|
      f.write(self.web_post)
    end
  end
end
