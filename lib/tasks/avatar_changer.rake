task "avatar_change" => :environment do
  count = 0
  for u in User.all do
    puts u.image_url
    # if u.image_url == "http://localhost:3000/assets/default-avatar-a1077a7dc895698bf1f871aa89c3261b8da55a362a19e71d3a4ec03816f122e8.jpg"
    #   count= count+1
    # end
  end
  puts count
end
