
# reminder check for events comming
task :hourly_check_events_reminder => :environment do
  puts "hourly_check_events_reminder START =========================="
  Event.reminder
  puts "hourly_check_events_reminder DONE.==========================="
end



# require 'koala'
# require 'stringex'
 
# desc "Import posts and comments from a Facebook group"
# task "import:facebook_group" => :environment do
#   # Import configuration file
#   @config = YAML.load_file('config/import_facebook.yml')
#   TEST_MODE = @config['test_mode']
#   FB_TOKEN = @config['facebook_token']
#   FB_GROUP_NAME = @config['facebook_group_name']
#   DC_CATEGORY_NAME = @config['discourse_category_name']
#   DC_ADMIN = @config['discourse_admin']
#   REAL_EMAIL = @config['real_email_addresses']
#   GROUP_ID = @config['facebook_group_id'] 
#   if TEST_MODE then puts "\n*** Running in TEST mode. No changes to Discourse database are made\n".yellow end
#   unless REAL_EMAIL then puts "\n*** Using fake email addresses\n".yellow end

#   # Setup Facebook connection
#   fb_initialize_connection(FB_TOKEN)
   
#   # Collect IDs
#   # group_id = fb_get_group_id(FB_GROUP_NAME)
 
#   @fb_posts ||= [] # Initialize if needed

#   # Fetch all facebook posts
#   fb_fetch_posts(GROUP_ID, current_unix_time)
 
#   if TEST_MODE then
#     exit_script # We're done
#     dc_create_users_from_fb_writers
#   else
#     # Create users in Discourse
#     dc_create_users_from_fb_writers
 
#     # Backup Site Settings
#     # dc_backup_site_settings
 
#     # # Then set the temporary Site Settings we need
#     # dc_set_temporary_site_settings
 
#     # Create and/or set Discourse category
#     # dc_category = dc_get_or_create_category(DC_CATEGORY_NAME, DC_ADMIN)
 
#     # Import Facebooks posts into Discourse
#     fb_import_posts_into_dc(31)
 
#     # Restore Site Settings
#     dc_restore_site_settings
#   end
 
#   puts "\n*** DONE".green
#   # DONE!
# end
 
 
# ############################################################
# #### Methods
# ############################################################
 
# # Connect to the Facebook Graph API
# def fb_initialize_connection(token)
#   begin
#     @graph = Koala::Facebook::API.new(token)
#     test = @graph.get_object('me')
#   rescue Koala::Facebook::APIError => e
#     puts "\nERROR: Connection with Facebook failed\n#{e.message}".red
#     exit_script
#   end
 
#   puts "\nFacebook token accepted".green
# end
 
# def fb_fetch_posts(group_id, until_time)
#   # Fetch Facebook posts in batches and download writer/user info
#   @fb_posts = []
#   page = @graph.get_connections(group_id,'feed',{:since => until_time - 30.minutes.to_i})
#   puts until_time
#   # begin
#   @fb_posts += page
     
#   # end while page = page.next_page
#   # puts @fb_posts
#   @fb_posts.each do |post|
#       # puts "aaa"
#       fb_extract_writer(post) # Extract the writer from the post
#       if not post['comments'].nil? then
#         comments = post['comments']['data']
#         comments.each do |comment|
#         fb_extract_writer(comment)
#       end
#     end
#     # end
#   puts @fb_writers
#   puts "\nAmount of posts: #{@fb_posts.count.to_s}"
#   puts "Amount of writers: #{@fb_writers.count.to_s}"
# end
 
# # Import Facebook posts into Discourse
# def fb_import_posts_into_dc(dc_category)
#   post_count = 0
#   @fb_posts.each do |fb_post|

#       # if PostCustomField.where(name: 'fb_id', value:  fb_post['id']).count == 0 then
#         post_count += 1
    
#         # Get details of the writer of this post
#         fb_post_user = @fb_writers.find {|k| k['id'] == fb_post['from']['id'].to_s}
         
#         # Get the Discourse user of this writer
#           dc_user = dc_get_user(fb_post_user['id'])
#         # dc_user = dc_get_user(fb_username_to_dc(fb_post_user['name']))
       
#         # Facebook posts don't have a title, so use first 50 characters of the post as title
#         if fb_post['message'].nil? then
#               fb_post['message'] = 'EMPTY'
#         end
#         topic_title = fb_post['message'][0,50]
#         # Remove new lines and replace with a space
#         topic_title = topic_title.gsub( /\n/m, " " )
      
#         # progress = post_count.percent_of(@fb_posts.count).round.to_s
    
#         # puts "[#{progress}%]".blue + " Creating topic '" + topic_title.blue + " #{Time.at(Time.parse(DateTime.iso8601(fb_post['created_time']).to_s))}"
         
         
#         # forum = Forem::Forum.find_by_name(params[:location])
#         forum = Forem::Forum.find_by_id(dc_category)
#           topic = forum.topics.create({
#           user: dc_user,
#           subject: topic_title,
#           slug: topic_title.parameterize,
#           posts_attributes: [{
#             user: dc_user,
#             text: fb_post['message'],
#             facebook_post_id: fb_post['id']
#           }]})
#                   #     post_creator = PostCreator.new(dc_user,
#                   #                               raw: fb_post['message'],
#                   #                               title: topic_title,
#                   #                               archetype: 'regular',
#                   #                               category: DC_CATEGORY_NAME,
#                   #                               created_at: Time.at(Time.parse(DateTime.iso8601(fb_post['created_time']).to_s)))
#                   #     post = post_creator.create
                 
#                   #     # Everything set, save the topic
#                   #     unless post_creator.errors.present? then
#                   #         topic_id = post.topic.id
#                   #         post.custom_fields['fb_id'] = fb_post['id']
#                   #         post.save
#                   #         post_serializer = PostSerializer.new(post, scope: true, root: false)
              
#               	   # # NEXT LINE IS DISABLED - don't know what is it and what for, but it crashing process
#                   #         # post_serializer.topic_slug = post.topic.slug if post.topic.present?
              	    
#                   #         post_serializer.draft_sequence = DraftSequence.current(dc_user, post.topic.draft_key)
                 
#                   #     end
#       # end
#       # Now create the replies, using the Facebook comments
#       unless fb_post['comments'].nil? then
#         fb_post['comments']['data'].each do |comment|
#             # topic = Forem::Topic.find(params[:topic_id])
#             if PostCustomField.where(name: 'fb_id', value:  comment['id']).count == 0 then
#               # Get details of the writer of this comment
#               comment_user = @fb_writers.find {|k| k['id'] == comment['from']['id'].to_s}
 
#               # Get the Discourse user of this writer
#               #dc_user = dc_get_user(fb_username_to_dc(comment_user['name']))
#                 dc_user = dc_get_user(comment_user['id'])
               
#               if comment['message'].nil? then
#                   comment['message'] = 'EMPTY'
#               end
#               Forem::Post.create({
#                 topic: topic,
#                 user: dc_user,
#                 text: comment.message,
#                 created_at: comment.created_at,
#                 facebook_post_id: comment.id,
#                 notified: true
#               })
#               # post_creator = PostCreator.new(dc_user,
#               #                             raw: comment['message'],
#               #                             category: DC_CATEGORY_NAME,
#               #                             topic_id: topic_id,
#               #                             created_at: Time.at(Time.parse(DateTime.iso8601(comment['created_time']).to_s)))
 
#               # post = post_creator.create
   
#               # unless post_creator.errors.present? then
#               #     post.custom_fields['fb_id'] = comment['id']
#               #     post.save
#               #     post_serializer = PostSerializer.new(post, scope: true, root: false)

# 	    	  # NEXT LINE IS DISABLED - don't know what is it and what for, but it crashing process
#                   #post_serializer.topic_slug = post.topic.slug if post.topic.present?
                  
# 		  # post_serializer.draft_sequence = DraftSequence.current(dc_user, post.topic.draft_key)
#               # end
#             end
#         end
#       end
#   end
#   puts " - #{post_count.to_s} Posts imported".green
# end
 
# # Returns the Discourse category where imported Facebook posts will go
# def dc_get_or_create_category(name, owner)
#   if Category.where('name = ?', name).empty? then
#     puts "Creating category '#{name}'"
#     owner = User.where('username = ?', owner).first
#     category = Category.create!(name: name, user_id: owner.id)
#   else
#     puts "Category '#{name}' exists"
#     category = Category.where('name = ?', name).first
#   end
# end
 
# # Create a Discourse user with Facebook info unless it already exists
# def dc_create_users_from_fb_writers
  
#     # if user = users.fetch(comment.from_id, false)
#     #       user = user.first
#     #     elsif user = User.find_by(email: "#{comment.from_id}@fb-user-id.com")
#     #       users[comment.from_id] = user
#     #     else
#     #       user = Services::CreateUserFromFacebookComment.new(comment.from).create_user
#     #       users[comment.from_id] = user
#     #     end
#   new_user_count = 0
#   @fb_writers.each do |fb_writer|
#     # Setup Discourse username
#     # dc_username = fb_username_to_dc(fb_writer['name'])
#     dc_fbid = fb_writer['id']
#     dc_username = fb_writer['name']
#     # # Create email address for user
#     # if fb_writer['email'].nil? then
#     #   dc_email = dc_username + "@localhost.fake"
#     # else
#     #   if REAL_EMAIL then
#     #     dc_email = fb_writer['email']
#     #   else
#     #     dc_email = fb_writer['email'] + '.fake'
#     #   end
#     # end
 
#     # Create user if it doesn't exist
    
#   if user = User.find_by(uid: dc_fbid)
#       # user = user.first
#   else if user = User.find_by(email: "#{dc_fbid}@fb-user-id.com")
#       # user = user.first
#   else if  
#       user = Services::CreateUserFromFacebookComment.new(fb_writer).create_user
#       new_user_count += 1
#   end 
   
   
#   #   if User.where('username = ?', dc_username).empty? then
#   #     dc_user = User.create!(username: dc_username,
#   #                           name: fb_writer['name'],
#   #                           email: dc_email,
#   #                           approved: true,
#   #                           approved_by_id: dc_get_user_id(DC_ADMIN))
#   # dc_user.activate; 
#   #     # Create Facebook credentials so the user could login later and claim his account
#   #     FacebookUserInfo.create!(user_id: dc_user.id,
#   #                             facebook_user_id: fb_writer['id'].to_i,
#   #                             username: fb_writer['name'],
#   #                             first_name: fb_writer['first_name'],
#   #                             last_name: fb_writer['last_name'],
#   #                             name: fb_writer['name'].tr(' ', '_'),
#   #                             link: fb_writer['link'])
#       # puts "User #{fb_writer['name']} (#{dc_username} / #{dc_email}) created".green
#     # end
#   end
#   puts  new_user_count
# end
 
# # Backup site settings


# # Check if user exists
# # For some really weird reason this method returns the opposite value
# # So if it did find the user, the result is false
# def dc_user_exists(name)
#   User.where('username = ?', name).exists?
# end
 
# def dc_get_user_id(name)
#   User.where('username = ?', name).first.id
# end
 
# def dc_get_user(uid)
#   User.where('uid = ?', name).first
# end
 
# # Returns current unix time
# def current_unix_time
#   Time.now.to_i
# end
 
# def unix_to_human_time(unix_time)
#   Time.at(unix_time).strftime("%d/%m/%Y %H:%M")
# end
 
# # Exit the script
# def exit_script
#   puts "\nScript will now exit\n".yellow
#   exit
# end
 
# def fb_extract_writer(post)
#   @fb_writers ||= [] # Initialize if needed
 
#   writer = post['from']['id'] 
#   # Fetch user info from Facebook and add to writers array
#   unless @fb_writers.any? {|w| w['id'] == writer.to_s}
#     @fb_writers << @graph.get_object(writer)
#   end
# end
 
# def fb_username_to_dc(name)
#   # Create username from full name, only letters and numbers
#   username = name.to_ascii.downcase.tr('^A-Za-z0-9', '')
 
#   # Maximum length of a Discourse username is 15 characters
#   username = username[0,15]

#   return username
# end
# end 
# # Add colors to class String
# class String
#   def red
#     colorize(self, 31);
#   end
 
#   def green
#     colorize(self, 32);
#   end
 
#   def yellow
#     colorize(self, 33);
#   end
 
#   def blue
#     colorize(self, 34);
#   end
 
#   def colorize(text, color_code)
#     "\033[#{color_code}m#{text}\033[0m"
#   end
# end
 
# # Calculate percentage
# class Numeric
#   def percent_of(n)
#     self.to_f / n.to_f * 100.0
#   end
# end



