json.array!(@profile_videos) do |profile_video|
  json.extract! profile_video, :id, :video, :user_id
  json.url profile_video_url(profile_video, format: :json)
end
