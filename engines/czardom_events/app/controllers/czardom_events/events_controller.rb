module CzardomEvents
  class EventsController < EventsApplicationController
    before_action :find_event, only: [:show, :join, :leave]
    load_and_authorize_resource

    def follow
      event = Event.find(params[:event_id].to_i)
      user_id = params[:user_id].to_i
      if event.can_follow(user_id)
        event_follower = event.event_followers.where(user_id: user_id).first
        event_follower.destroy!
      else
        event.event_followers.create(user_id: user_id)
      end
      redirect_to event_path(event)
    end

    def index
      @events = @events.order(:start_at)
      @event_followings = Event.where(id: current_user.event_followers.pluck(:event_id))

      if params[:regions].present?
        regions = Region.find(params[:regions])
        event_ids = regions.map { |r| r.results.map(&:addressable_id) }.flatten.uniq
        @events.where!(id: event_ids)
        @event_followings.where!(id: event_ids)
      end

      if params[:groups].present?
        @events.where!(eventable_type: 'Group', eventable_id: params[:groups])
        @event_followings.where!(eventable_type: 'Group', eventable_id: params[:groups])
      end

      if params[:date].present?
        @events.where!('date(start_at) = ?', params[:date])
        @event_followings.where!('date(start_at) = ?', params[:date])
      else
        @events = @events.current
        @event_followings = @event_followings.current
      end

      # should not include duplicate events
      @event_followings = @event_followings.where("id NOT IN (?)", @events.pluck(:id))
      @events += @event_followings

      respond_with @events
    end

    def future
      @events = @events.order(:start_at)
      @event_followings = Event.where(id: current_user.event_followers.pluck(:event_id))

      if params[:regions].present?
        regions = Region.find(params[:regions])
        event_ids = regions.map { |r| r.results.map(&:addressable_id) }.flatten.uniq
        @events.where!(id: event_ids)
        @event_followings.where!(id: event_ids)
      end

      if params[:groups].present?
        @events.where!(eventable_type: 'Group', eventable_id: params[:groups])
        @event_followings.where!(eventable_type: 'Group', eventable_id: params[:groups])
      end

      if params[:date].present?
        @events.where!('date(start_at) = ?', params[:date])
        @event_followings.where!('date(start_at) = ?', params[:date])
      else
        @events = @events.current
        @event_followings = @event_followings.current
      end

      # should not include duplicate events
      @event_followings = @event_followings.where("id NOT IN (?)", @events.pluck(:id))
      @events += @event_followings

      respond_with @events
    end

    def count_by_day
      start = params[:start]
      stop = params[:end]
      @events = Event.all

      if params[:regions].present?
        regions = Region.find(params[:regions])
        event_ids = regions.map { |r| r.results.map(&:addressable_id) }.flatten.uniq
        @events.where!(id: event_ids)
      end

      if params[:groups].present?
        @events.where!(eventable_type: 'Group', eventable_id: params[:groups])
      end

      # @events = @events.reorder(nil)
      #   .group('date(start_at)')
      #   .where('date(start_at) >= ? and date(start_at) <= ?', start, stop)
      #   .count

      @events = @events.reorder(nil).where('date(start_at) >= ? and date(start_at) <= ?', start, stop)
      respond_with @events
    end

    def show
      if @event.topic !=nil
        @posts = @event.topic.posts.limit(5)
      else
        @posts = nil
      end
    end

    def new
      @event.build_address
      @event_videos = @event.event_videos.build
      @event_images = @event.event_images.build
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
        flash[:success] = "Thank you for your event submission. Here's what you event looks like. <br> If you need to manage a guest list for your event on mobile phones, check out an amazing offer from our partner <a href='https://www.zkipster.com/czardom/?utm_source=Czardom&utm_medium=banner&utm_campaign=1604%20Czardom%20Partner%20Leads' target='_blank'>Zkipster.</a>"
        # track_activity @event
       # Event.add_user(@event.id, current_user.id)
        redirect_to @event
      else
        render :new
      end
    end

    def update
      @event.eventable = eventable

      unless @event.topic_id.present?
        if eventable.class.name == 'User'
          create_user_events_topic(@event)
        elsif eventable.class.name == 'Group'
          create_group_events_topic(eventable, @event)
        end
      end

      if @event.update_attributes(event_params)
        redirect_to @event
      else 
        render :edit
      end
    end

    def destroy
      @event.destroy
      redirect_to root_path
    end

    def join
      Event.add_user(@event.id, current_user.id)
      # track_activity @event, 'rsvp'
      redirect_to event_path(params[:id])
    end

    def leave
      Event.remove_user(params[:id], current_user.id)
      redirect_to event_path(params[:id])
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
      group_id = params.fetch(:group_id, false)
      if group_id.present?
        @postable = Group.find(group_id)
      else
        @postable = current_user
      end
    end

    def find_event
      @event ||= Event.friendly.find(params[:id])
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
            text: %Q{#{event.description}<br /><br /><a href="#{event_url(event)}">#{event_url(event)}</a>},
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
            text: %Q{#{event.description}<br /><br /><a href="#{event_url(event)}">#{event_url(event)}</a>},
            notified: true
          }]
        )

        event.update_attributes(topic_id: topic.id)
      end
    end


  end
end
