class Api::V1::ConversationsController  < Api::V1::BaseController
  skip_before_action :verify_authenticity_token, only: [:create, :reply]

  def index
    @conversations = current_user.mailbox.conversations
    # @conversations = current_user.messages
    if @conversations.present?
      messages = []
      @conversations.each do |conversation|
        recipients = []
        conversation.recipients.each_with_index do |recipient|
          unless recipient == current_user
            friend = Hash.new
            friend["name"] = "#{recipient.first_name}"+" "+"#{recipient.last_name}"
            friend["email"] = recipient.email
            friend["avatar"] = recipient.image.url
            recipients << friend
          end
        end
        messages << conversation.messages.last.as_json.merge(:recipients => recipients)
      end
      render :status => 200,
           :json => { :success => true,
                      :info => "All Conversations",
                      :data => { :conversations => messages } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "All Conversations",
                      :data => { :conversations => "No conversation..." } }
    end
  end

  def create
    recipients = []
    if params[:conversation][:recipients].present?
      params[:conversation][:recipients].each do |recipient|
        recipients << User.find(recipient.last)
      end
      conversations = current_user.send_message(recipients,params[:conversation][:body],params[:conversation][:subject])
      render :status => 200,
           :json => { :success => true,
                      :info => "Messages sent successfully..."}
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Messages",
                      :data => { :messages => "Please enter recipient email id..." } }
    end
  end

  def show
    conversation = current_user.mailbox.conversations.find(params[:id])
    unless  conversation.nil?
      messages = []
      conversation.messages.each do |message|
        messages << message.as_json.merge(:author_avatar => message.sender.image.url)
      end
      # receipts = conversation.receipts_for current_user
      # receipts.each do |receipt|
      #   messages << receipt.message
      # end
      render :status => 200,
             :json => { :success => true,
                        :info => "conversation",
                        :data => { :messages => messages } }
    else
      render :status => 400,
             :json => { :success => false,
                        :info => "please pass right conversation id for logged user..."}
    end
  end

  def inbox
    messages = []
    receipts = []
    # recipient = User.find(params[:recipient_id])
    conversations = current_user.mailbox.inbox
    conversations.each do |cnvrstn|
      rp = cnvrstn.receipts_for current_user
      receipts << rp.first
    end
    receipts.each do |receipt|
      message = receipt.message
      if message.sender_type == "Event"
        user = message.sender.user
        messages << receipt.message.as_json.merge(:username => user.full_name, :user_avatar => user.avatar, :msg_sent_at => message.created_at)
      else
        user = message.sender
        messages << message.as_json.merge(:username => user.full_name, :user_avatar => user.avatar, :msg_sent_at => message.created_at)
      end
    end
    render :status => 200,
           :json => { :success => true,
                      :info => "Inbox",
                      :data => { :conversations => messages } }
  end
  def get_last_conversation
    messages = []
    # recipient = User.find(params[:recipient_id])
    conversation = current_user.mailbox.inbox.first
    receipts = conversation.receipts_for current_user
    receipts.each do |receipt|
      messages << receipt.message
    end
    render :status => 200,
           :json => { :success => true,
                      :info => "conversation",
                      :data => { :conversation => messages } }
  end

  def reply
    conversation = current_user.mailbox.conversations.find(params[:conversation][:conversation_id])
    # conversation = recipient.mailbox.inbox.first
    unless  conversation.nil?
      current_user.reply_to_conversation(conversation, params[:conversation][:body])
      render :status => 200,
             :json => { :success => true,
                        :info => "Reply sent successfully..." }
    else
      render :status => 400,
             :json => { :success => false,
                        :info => "please pass right conversation id for logged user..."}
    end
  end

  def trash
    conversation = current_user.mailbox.conversations.find(params[:conversation_id])
    # conversation = current_user.mailbox.inbox.find(params[:conversation_id])
    # recipient = User.find(params[:recipient_id])
    # conversation = recipient.mailbox.inbox.first
    conversation.move_to_trash(current_user)
    render :status => 200,
           :json => { :success => true,
                      :info => "Conversation moved into trash..." }
  end

  def untrash
    conversation = current_user.mailbox.trash.find(params[:conversation_id])
    conversation.untrash(current_user)
    render :status => 200,
           :json => { :success => true,
                      :info => "Conversation moved into inbox..." }
  end

  def sent
    messages = []
    receipts = []
    # recipient = User.find(params[:recipient_id])
    conversations = current_user.mailbox.sentbox
    conversations.each do |cnvrstn|
      rp = cnvrstn.receipts_for current_user
      receipts << rp.first
    end
    receipts.each do |receipt|
      messages << receipt.message
    end
    render :status => 200,
           :json => { :success => true,
                      :info => "sent",
                      :data => { :conversations => messages } }
  end
end