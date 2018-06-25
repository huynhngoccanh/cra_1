require 'koala'
require 'stringex'
 
desc "Import posts and comments from a Facebook group"
task "fb_import" => :environment do
  # Import configuration file
  @config = YAML.load_file('config/import_facebook.yml')
  TEST_MODE = @config['test_mode']
  FB_TOKEN = @config['fb_token']
  FB_GROUP_NAME = @config['fb_name']
  DC_CATEGORY_NAME = @config['discourse_category_name']
  DC_ADMIN = @config['discourse_admin']
  REAL_EMAIL = @config['real_email_addresses']
  GROUP_ID = @config['fb_base'] 
  TECH_GROUP_ID = @config['fb_tech'] 
  BEAUTY_GROUP_ID = @config['fb_beauty'] 
  MOTHERS_GROUP_ID = @config['fb_mothers'] 
  MIAMISWIM_GROUP_ID = @config['fb_miamiswim'] 
  CANNE_GROUP_ID = @config['fb_canne'] 
  EMMY_GROUP_ID = @config['fb_emmyczar'] 
  SXSW_GROUP_ID = @config['fb_sxsw'] 
  MOMBLOG_GROUP_ID = @config['fb_momblog'] 
  BACKTOSCHOOL_GROUP_ID = @config['fb_backtoschool'] 
  TRAVEL_GROUP_ID = @config['fb_travelczars'] 
  CAUSE_GROUP_ID = @config['fb_cause'] 
  HAMPTONS_GROUP_ID = @config['fb_hamptons'] 
  FASHIONWEEK_GROUP_ID = @config['fb_fashion_week_ny'] 
  MOM_CZLOGGERS_GROUP_ID = @config['fb_mom_czloggers'] 
  COACHELLA_GROUP_ID = @config['fb_coachella'] 
  OSCARS_GROUP_ID = @config['fb_oscars'] 
  SUPER_BOWL_GROUP_ID = @config['fb_super_bowl'] 
  SPORTS_GROUP_ID = @config['fb_sports'] 
  MUSIC_GROUP_ID = @config['fb_music'] 
  FATHER_GROUP_ID = @config['fb_father'] 
  UBRAN_GROUP_ID = @config['fb_urban'] 
  CANNES_GROUP_ID = @config['fb_cannes'] 
  TRIBECA_GROUP_ID = @config['fb_tribeca_film'] 
  SUNDANCE_GROUP_ID = @config['fb_sundance']
  HOLIDAY_GROUP_ID = @config['fb_holiday_guide'] 
  WEDDING_GROUP_ID = @config['fb_wedding'] 
  
  ART_BASEEL_GROUP_ID = @config['fb_art_bassel']
  SOUTH_BEACH_GROUP_ID = @config['fb_south_beach_food'] 
  NBA_ALLSTAR_GROUP_ID = @config['fb_nba_allstar'] 
  
  CZ_FB_ID = @config['cz_facebook'] 
  CZ_TECH_ID = @config['cz_tech']
  CZ_BEAUTY_ID = @config['cz_beauty']
  CZ_MOTHERS_ID = @config['cz_mothers']
  CZ_MIAMISWIM_ID = @config['cz_miamiswim']
  CZ_CANNE_ID = @config['cz_canne']
  CZ_EMMY_ID = @config['cz_emmy']
  CZ_SXSW_ID = @config['cz_sxsw']
  CZ_BLOG_ID = @config['cz_blog']
  CZ_BACKTOSCHOOL_ID = @config['cz_backtoschool']
  CZ_TRAVEL_ID = @config['cz_travel']
  CZ_CAUSE_ID = @config['cz_cause']
  CZ_HAMPTONS_ID = @config['cz_hamptons']
  CZ_FASHIONWEEK_ID = @config['cz_fashionweek_ny']
  CZ_MOM_CZLOGGERS_ID = @config['cz_mom_czloggers'] 
  CZ_COACHELLA_ID = @config['cz_coachella'] 
  CZ_OSCARS_ID = @config['cz_oscars'] 
  CZ_SUPER_BOWL_ID = @config['cz_super_bowl'] 
  CZ_SPORTS_ID = @config['cz_sports'] 
  CZ_MUSIC_ID = @config['cz_music'] 
  CZ_FATHER_ID = @config['cz_father'] 
  CZ_URBAN_ID = @config['cz_urban'] 
  CZ_CANNES_ID = @config['cz_cannes'] 
  CZ_TRIBECA_ID = @config['cz_tribeca_film'] 
  CZ_SUNDANCE_ID = @config['cz_sundance']  
  
  CZ_HOLIDAY_ID = @config['cz_holiday_guide'] 
  CZ_WEDDING_ID = @config['cz_wedding']  

  CZ_ART_BASSEL_ID = @config['cz_art_bassel'] 
  CZ_SOUTH_BEACH_ID = @config['cz_south_beach_food']  
  CZ_NBA_ALLSTAR_ID = @config['cz_nba_allstar']   
# cz_art_bassel: 84
# cz_south_beach_food: 90
# cz_nba_allstar: 91


  # Setup Facebook connection
  fb_initialize_connection(FB_TOKEN)
  @fb_posts ||= [] # Initialize if needed

  # Fetch all facebook posts
  
 
  if TEST_MODE then
    # exit_script # We're done
    # @posts = Forem::Topic.where(:subject =>"EMPTY...")
    # @posts.each do |post|
    #   comments = Forem::Post.where(:topic_id=>post.id).destroy_all
    #   # puts comments.size
    # end
    # Forem::Topic.where(:subject =>"EMPTY...").destroy_all
    # puts @posts.size
      # if(post['text'] == "EMPTY...") then
      #   put "1"
      # end

    
  else
     fb_fetch_posts(GROUP_ID)
     # Create users in Discourse
     # dc_create_users_from_fb_writers
     dc_create_users_from_fb_writers
      # # Import Facebooks posts into Discourse
     fb_import_posts_into_dc(CZ_FB_ID)
     
     fb_fetch_posts(TECH_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_TECH_ID)

     fb_fetch_posts(BEAUTY_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_BEAUTY_ID)
    
     fb_fetch_posts(MOTHERS_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_MOTHERS_ID)
     
     fb_fetch_posts(MIAMISWIM_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_MIAMISWIM_ID)
     
     
     fb_fetch_posts(CANNE_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_CANNE_ID)
     
     fb_fetch_posts(EMMY_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_EMMY_ID)
     
     fb_fetch_posts(SXSW_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_SXSW_ID)
     
     fb_fetch_posts(MOMBLOG_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_BLOG_ID)
     
     fb_fetch_posts(BACKTOSCHOOL_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_BACKTOSCHOOL_ID)    

     fb_fetch_posts(TRAVEL_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_TRAVEL_ID)    
     
     fb_fetch_posts(CAUSE_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_CAUSE_ID)
     
     fb_fetch_posts(HAMPTONS_GROUP_ID)
     dc_create_users_from_fb_writers
     fb_import_posts_into_dc(CZ_HAMPTONS_ID)
    
    fb_fetch_posts(FASHIONWEEK_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_FASHIONWEEK_ID)
    
    fb_fetch_posts(MOM_CZLOGGERS_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_MOM_CZLOGGERS_ID)
    
     fb_fetch_posts(COACHELLA_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_COACHELLA_ID)
    
    fb_fetch_posts(OSCARS_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_OSCARS_ID)
    
    fb_fetch_posts(SUPER_BOWL_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(SUPER_BOWL_GROUP_ID)
    
    fb_fetch_posts(SPORTS_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_SPORTS_ID)
    
    fb_fetch_posts(MUSIC_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_MUSIC_ID)
    
    fb_fetch_posts(FATHER_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_FATHER_ID)
    
    fb_fetch_posts(UBRAN_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_URBAN_ID)
    
    fb_fetch_posts(CANNES_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_CANNES_ID)
    
    fb_fetch_posts(TRIBECA_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_TRIBECA_ID)
    
    fb_fetch_posts(SUNDANCE_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_SUNDANCE_ID)
    
    fb_fetch_posts(HOLIDAY_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_HOLIDAY_ID)
    
    fb_fetch_posts(WEDDING_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_WEDDING_ID)    
    
    fb_fetch_posts(ART_BASEEL_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_ART_BASSEL_ID)
    
    fb_fetch_posts(SOUTH_BEACH_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_SOUTH_BEACH_ID)
    
    fb_fetch_posts(NBA_ALLSTAR_GROUP_ID)
    dc_create_users_from_fb_writers
    fb_import_posts_into_dc(CZ_NBA_ALLSTAR_ID)
    # # Restore Site Settings
    # dc_restore_site_settings
  end
 
  puts "\n*** DONE".green
  # DONE!
end
# ############################################################
# #### Methods
# ############################################################
def fb_extract_writer(post)
  @fb_writers ||= [] # Initialize if needed
 
  writer = post['from']['id'] 
  # Fetch user info from Facebook and add to writers array
  unless @fb_writers.any? {|w| w['id'] == writer.to_s}
    @fb_writers << @graph.get_object(writer)
  end
end

# # Connect to the Facebook Graph API

def fb_initialize_connection(token)
  begin
    @graph = Koala::Facebook::API.new(token)
    @graph.get_object('me')
  rescue Koala::Facebook::APIError => e
    puts "\nERROR: Connection with Facebook failed\n#{e.message}".red
    exit_script
  end
 
  puts "\nFacebook token accepted".green
end

def fb_fetch_posts(group)
  # Fetch Facebook posts in batches and download writer/user info
  @fb_posts = []
 # page = @graph.get_connections(group,'feed',{ :fields => ['message','id','from', 'updated_time'],:since => Time.now.to_i - 15.minutes.to_i})
  page = @graph.get_connections(group,'feed',{ :fields => ['message','id','from', 'updated_time'],:since => Time.now.to_i - 10.day.to_i})
  #page = @graph.get_connections(group,'feed',{:since => Time.now.to_i - 1.day.to_i}) 
  # begin
  @fb_posts += page
  # end while page = page.next_page
  # puts @fb_posts
  @fb_posts.each do |post|
      fb_extract_writer(post) # Extract the writer from the post
      if not post['comments'].nil? then
        comments = post['comments']['data']
        comments.each do |comment|
           fb_extract_writer(comment)
        end
      end
  end
    # end
  # puts @fb_writers
  unless @fb_posts.nil?
     puts "\nAmount of posts: #{@fb_posts.count.to_s}"
  end
  unless @fb_writers.nil?
      puts "Amount of writers: #{@fb_writers.count.to_s}"
  end
  # puts "\nAmount of posts: #{@fb_posts.count.to_s}"
  # puts "Amount of writers: #{@fb_writers.count.to_s}"
end


def dc_create_users_from_fb_writers
  
    # if user = users.fetch(comment.from, false)
    #       user = user.first
    #     elsif user = User.find_by(email: "#{comment.from}@fb-user-id.com")
    #       users[comment.from] = user
    #     else
    #       user = Services::CreateUserFromFacebookComment.new(comment.from).create_user
    #       users[comment.from] = user
    #     end
  new_user_count = 0
  unless @fb_writers.nil?
    @fb_writers.each do |fb_writer|
      dc_fbid = fb_writer['id']
      # dc_username = fb_writer['name']
      
      user = User.where(uid: dc_fbid)    
      if user.empty?
          # user = user.first
          user = User.where(email: "#{dc_fbid}@fb-user-id.com")
        if user.empty?
            user = Services::CreateUserFromFacebookComment.new(fb_writer).create_user
            new_user_count += 1
        else  
            user = user.first
            user.update_attribute('uid', dc_fbid)
        end 
      else 
        user = user.first
      end
    end
  end
  puts  new_user_count


def fb_import_posts_into_dc(dc_category)
  post_count = 0
  @fb_posts.each do |fb_post|

      # if PostCustomField.where(name: 'fb', value:  fb_post['id']).count == 0 then
    post_count += 1

    # Get details of the writer of this post
    fb_post_user = @fb_writers.find {|k| k['id'] == fb_post['from']['id'].to_s}
     
    # Get the Discourse user of this writer
    dc_user = dc_get_user(fb_post_user['id'])
    # puts fb_post
    # puts dc_user  
    # puts fb_post_user
    # dc_user = dc_get_user(fb_username_to_dc(fb_post_user['name']))
   
    # Facebook posts don't have a title, so use first 50 characters of the post as title
    next if fb_post['message'].nil?
    # if fb_post['message'].nil? then
    #       fb_post['message'] = 'EMPTY'
    # end
    topic_title_origin = fb_post['message'][0,250]
    # Remove new lines and replace with a space
    topic_title = topic_title_origin.gsub( /\n/m, " " )
  
    # progress = post_count.percent_of(@fb_posts.count).round.to_s
    # puts "[#{progress}%]".blue + " Creating topic '" + topic_title.blue + " #{Time.at(Time.parse(DateTime.iso8601(fb_post['created_time']).to_s))}"
     
  
    forum = Forem::Forum.find_by_id(dc_category)
   
    new_slug = Forem::Topic.maximum(:id).next.to_s + "-"+ topic_title.parameterize
    if topic_title_origin.size > 249
      topic_title = topic_title + "..."
    end
    
    flag = true

    while flag do 
      topic = forum.topics.where(slug: new_slug)
      if !topic.empty? then
        topic = topic.first
        flag = false
      else
         _topic = Forem::Topic.where(slug: new_slug)
         if _topic.empty? then
            topic = forum.topics.create({
              user: dc_user,
              subject: topic_title,
              created_at: fb_post['created_time'],
              slug: new_slug,
              posts_attributes: [{
                user: dc_user,
                text: fb_post['message'],
                facebook_post_id: fb_post['id']
              }]})
             flag = false 
         else
            # binding.pry
            new_slug = new_slug + "_"
         end
      end
     end
     
      # Now create the replies, using the Facebook comments
    unless fb_post['comments'].nil? then
      fb_post['comments']['data'].each do |comment|
          # topic = Forem::Topic.find(params[:topic])
          if Forem::Post.where(facebook_post_id: comment['id']).count == 0 then
            # Get details of the writer of this comment
                  comment_user = @fb_writers.find {|k| k['id'] == comment['from']['id'].to_s}

            # # Get the Discourse user of this writer
            #dc_user = dc_get_user(fb_username_to_dc(comment_user['name']))
            dc_user = dc_get_user(comment_user['id'])
             
            if comment['message'].nil? then
              #not import comment
                comment['message'] = 'EMPTY'
            else
           
              if(topic) then
                 Forem::Post.create({
                  topic: topic,
                  user: dc_user,
                  text: comment['message'],
                  created_at: comment['created_time'],
                  facebook_post_id: comment['id'],
                  notified: true
                })
              end
            end

           
          end
      end
    end
  end
  puts " - #{post_count.to_s} Posts imported".green
end
 

def current_unix_time
  Time.now.to_i
end

def dc_get_user(uid)
  User.where('uid = ?', uid).first
end
end 
# Add colors to class String
class String
  def red
    colorize(self, 31);
  end
  
  def numeric?(lookAhead)
    lookAhead =~ /[0-9]/
  end
  def green
    colorize(self, 32);
  end
 
  def yellow
    colorize(self, 33);
  end
 
  def blue
    colorize(self, 34);
  end
 
  def colorize(text, color_code)
    "\033[#{color_code}m#{text}\033[0m"
  end
end
