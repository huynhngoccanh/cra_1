class Api::V1::EventsController  < Api::V1::BaseController
  skip_before_action :verify_authenticity_token, only: [:filetered_events, :create]

  def index
    @events = Event.where('start_at > ?',Date.current)

    # respond_with @events
    if @events.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Events",
                      :data => { :upcoming_events => @events.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Events",
                      :data => { :upcoming_events => "No upcoming events..." } }
    end
  end

  def filetered_events
    @events = Event.where('start_at > ?',Date.parse(params[:event][:date]))
    if @events.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Events",
                      :data => { :events => @events } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Events",
                      :data => { :events => "No events..." } }
    end
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    @event.eventable = eventable

    if @event.save
      if eventable.class.name == 'User'
        create_user_events_topic(@event)
      elsif eventable.class.name == 'Group'
        create_group_events_topic(eventable, @event)
      end
      if params[:event][:images].present?
        params[:event][:images].each do |image|
          @event.event_images.build(:image => image).save
        end
      end

      if params[:event][:video].present?
        @event.event_videos.build(:video_url => params[:event][:video]).save
      end
      render :status => 200,
           :json => { :success => true,
                      :info => "Event",
                      :data => { :event => @event } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Event",
                      :data => { :event => @event.errors.full_messages.join(", ") } }
    end
  end

  private

    def event_params
      params.require(:event).permit(
        :title, :description,
        :start_at, :end_at, :timeframe,
        :location,
        :video,
        :web_url,
        :event_videos_attributes => [:video_url, :id ],
        :event_images_attributes => [:image, :id ],
        :address_attributes => [:street, :street2, :city, :state, :zip_code, :country, :id]
      )
    end

    def eventable
      return @postable unless @postable.nil?
      group_id = params[:event].fetch(:group_id, false)
      if group_id.present?
        @postable = Group.find(group_id)
      else
        @postable = current_user
      end
    end

    def create_user_events_topic(event)
      ActiveRecord::Base.transaction do
        category = Forem::Category.find_or_create_by!(name: 'General')

        unless forum = Forem::Forum.find_by(name: 'User Events')
          forum = Forem::Forum.create!(name: 'User Events', description: "See what's coming up in the PR world", category: category)
        end

        topic = forum.topics.create!(
          subject: "Event: #{event.title}",
          user: current_user,
          posts_attributes: [{
            text: %Q{#{event.description}},
            notified: true
          }]
        )

        event.update_attributes(topic_id: topic.id)
      end
    end

    def create_group_events_topic(group, event)
      ActiveRecord::Base.transaction do
        group.create_forum
        forum = group.forum

        topic = forum.topics.create!(
          subject: "Event: #{event.title}",
          user: current_user,
          posts_attributes: [{
            text: %Q{#{event.description}},
            notified: true
          }]
        )

        event.update_attributes(topic_id: topic.id)
      end
    end
end