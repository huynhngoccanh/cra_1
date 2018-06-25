module UsersHelper

  def avatar_tag(user, options = {})
    option = {}
    option[:alt] = user.try(:full_name)
    classes = options.fetch(:class, '')
    option[:class] = "#{classes} user-avatar"

    # if(options.fetch(:size, {}) == ":tiny")
    #   actual_size = "48 * 48"
    # else
    #   actual_size = "60 * 60"
    # end

    #image_tag user.image_url,option, size: "#{actual_size}"
    image_tag user.image_url(options.fetch(:size, {})), options
  end

  def edit_id(user)
    return if user == current_user
    user
  end

  def generate_crown(user)
    points = user.total_point.to_i
    gold_count = points / 50

    if gold_count > 6
      gold_count = 6
      silver_count = 0
      iron_count = 0
    else
      silver_count = (points % 50) / 10
      iron_count = (points % 10) / 2
    end

    html = ""
    gold_count.times do
      html << image_tag("1.png", alt: "Golden crown", size: "35", 'data-toggle' => 'tooltip', title: 'Czardom Golden Crown')
    end
    silver_count.times do
      html << image_tag("2.png", alt: "Silver crown", size: "30", 'data-toggle' => 'tooltip', title: 'Czardom Silver Crown')
    end
    iron_count.times do
      html << image_tag("3.png", alt: "Iron crown", size: "25", 'data-toggle' => 'tooltip', title: 'Czardom Iron Crown')
    end

    html
  end

  def format_number_follower(user)
    follower_total = user.followers.count
    follower_total > 500 ? "500+" : follower_total
  end

end
