module ApplicationHelper
  def is_test_mode?(_attrs = {})
    api_key = _attrs[:api_key]
    return api_key.split("sk_test").count > 1
  end
  def stripe_testing_nos
    ["4242424242424242","4000056655665556","5555555555554444","2223003122003222","5200828282828210","5105105105105100","378282246310005","371449635398431","6011111111111117","6011000990139424","30569309025904","38520000023237","3530111333300000","4000000760000002","4000001240000000","4012888888881881","4000004840000008","4000000000003055","4000000000003063","378282246310005","4000000000000077","4000000000000093","4000000000000010","4000000000000028","4000000000000036","4000000000000044","4000000000000101","4000000000000341","4000000000009235","4000000000000002","4100000000000019","4000000000000127","4000000000000069","4000000000000119","4242424242424241","4000000000000259","3714 4963 5398 431"]
  end

  def extract_url(str)
    URI.extract(str, /http(s)?/)
  end

  def make_image_link(str)
    begin
    url = extract_url(str).first
    object = LinkThumbnailer.generate(url) unless url.blank?
    rescue
    end

  end

  def all_username
    User.pluck(:slug).compact
  end

  # need html_safe then
  def make_link_for_usernames(text)
    text.gsub /(?:^|\W)
        @((?>[a-z0-9][a-z0-9-]*))
        (?!\/)
        (?=\.+[ \t\W]|\.+$|[^0-9a-zA-Z_.]|$)/ix do |slug|
      # link_to(slug, main_app.user_path(slug.gsub('@', '')))
      slug = slug.gsub('@', '')
      link_to(slug, "/users/#{slug}")
    end
  end

  def page_title(options = {})
    return unless content_for?(:page_title)
    title = ''

    if options.fetch(:prepend, false)
      title << options[:prepend] + " "
    end

    title << content_for(:page_title)

    if options.fetch(:append, false)
      title << " " + options[:append]
    end

    title
  end

  def title(page_title)
    content_for(:page_title, page_title)
  end

  def preregister_path?
    request.url =~ /preregister/
  end

  def generate_notification_description(notification)
    "#{notification.description} - <i><small>#{time_ago_in_words(notification.created_at) + ' ago'}</small></i>"
  end

  def generate_notification_url(notification)
    "#{notification.url}?ref_notify=#{notification.id}"
  end

  def should_hide_sidebar?
    hidden_paths = ["/map/", "/calendar/", "/complete", "onboarding/groups", "users/new"]
    hidden_paths.each do |key|
      return true if request.path.index(key).present?
    end
    false
  end

  def validate_start_value start_value
    if start_value > 0
      return (start_value - 1)
    else
      return 0
    end
  end

  def get_group forum_id
    group =  Group.find_by_forum_id(forum_id)
    unless group.nil?
      return group.id
    else
      return ""
    end
  end


  def relevant_posts(topic)
    topic.posts.size
  end

  def to_user_hash(user)
    {
      id: user.try(:id),
      deleted: user.is_a?(Forem::NilUser),
      first_name: user.try(:first_name),
      last_name: user.try(:last_name),
      full_name: [user.try(:first_name), user.try(:last_name)].join(' '),
      charter_member: user.try(:charter_member?) || false,
      profile_url: user_link(user),
      crowns: generate_crown(user),
      avatar: {
        small: user.image_url(:small),
        thumb: user.image_url(:thumb),
        large: user.image_url(:large)
      }
    }
  end

  def user_link(user)
    if user.is_a?(Forem::NilUser)
      '#'
    else
      main_app.user_path(user)
    end
  end
end
