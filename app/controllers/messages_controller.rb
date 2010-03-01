class MessagesController < ApplicationController
  
  before_filter :login_required
  
  # compose a new message
  def compose
    return unless request.post?
    invalid_user = []
    params[:message][:to].split(',').each do |user|
      # remove the whitespaces
      user.strip!
      # find the follower(s)
      follower=User.find_by_login(user)
      # follower must exist.
      (invalid_user << user; next) if follower.nil? || follower == current_user
      # saving the message
      new_message = Message.new(:originator => current_user, :follower => follower, :title => params[:message][:title], :body => params[:message][:body])
      # composing a message starts a thread, hence storing status of thread
      new_message.status = MessageStatus.new(:originator_inbox => MessageStatus::STATUS['deleted'], :originator_outbox => MessageStatus::STATUS['read'], :follower_inbox => MessageStatus::STATUS['unread'], :follower_outbox => MessageStatus::STATUS['deleted'])
      # it will save the status of thread
      new_message.save! 
      # update the thread id with self.id
      new_message.update_attribute(:thread_id, new_message.id)
    end
    flash[:notice] = (invalid_user.empty? ? "Your message has been sent." : "User #{invalid_user.join(' ')} seems invalid. Mail has been sent to rest of users.")
    redirect_to :action => 'outbox'
  end
  
  # reply to an existing message
  def reply
    return unless request.post?
    # find the thread
    thread = Message.find(params[:id])
    # find the last message of thread
    last_message = Message.find(:all, :conditions => ["thread_id = ?", thread.id], :order => 'created_at').last
    # if originator is sending more than 1 messages, handle it 
    if last_message.originator == current_user
      new_message = Message.create(:originator => current_user, :follower => last_message.follower, :title => "re: #{thread.title}", :body => params[:message][:body], :thread_id => thread.id)
      # check if the message has been deleted by the follower or originator, we need to restore that
      thread.status.update_attribute(:follower_inbox, 2) if thread.status.follower_inbox == 0
      thread.status.update_attribute(:originator_inbox, 2) if thread.status.originator_inbox == 0
    # normal case, follower replying to originator's message
    else
      # create a new message
      new_message = Message.create(:originator => current_user, :follower => last_message.originator, :title => "re: #{thread.title}", :body => params[:message][:body], :thread_id => thread.id)
      # check who is replying in the thread, is it follower or originator and update the flags as needed    
      if thread.follower == current_user
        thread.status.update_attributes(:originator_inbox => MessageStatus::STATUS['unread'], :follower_inbox => MessageStatus::STATUS['read'])
      else
        thread.status.update_attributes(:originator_inbox => MessageStatus::STATUS['read'], :follower_inbox => MessageStatus::STATUS['unread'])
      end
      # update the flags for outbox that are global
      thread.status.update_attributes(:originator_outbox => MessageStatus::STATUS['read'], :follower_outbox => MessageStatus::STATUS['read'])
    end
    
    redirect_to :action => 'inbox'
  end  
  
  # show all outbox threads
  def outbox
    @threads = []; @location = 'outbox'
    return if current_user.outbox_messages.blank?
    current_user.outbox_messages.each do |message|
      thread = Message.find(message.thread_id)
      ( current_user == thread.follower ? (@threads << thread if thread.status.follower_outbox != 0) : (@threads << thread if thread.status.originator_outbox != 0))
    end
    @threads.uniq!
  end
  
 # show all inbox threads
  def inbox
    @threads = []; @location = 'inbox'
    return if current_user.inbox_messages.blank?
    current_user.inbox_messages.each do |message|
      thread = Message.find(message.thread_id)
      # if i started the thread
      current_user == thread.originator ? (@threads << thread if thread.status.originator_inbox != 0) : (@threads << thread if thread.status.follower_inbox != 0)
    end
    @threads.uniq!
  end
  
  # it will be passed the thread id and will show the message in detail
  def show
    # find thread
    @thread = Message.find(params[:id])
    # read all the message for that thread
    @thread.status.update_attribute(:originator_inbox, MessageStatus::STATUS['read']) if @thread.status.originator_inbox == 2 && current_user == @thread.originator # he is looking @ his reply
    @thread.status.update_attribute(:originator_outbox, MessageStatus::STATUS['read']) if @thread.status.originator_outbox == 2
    @thread.status.update_attribute(:follower_inbox, MessageStatus::STATUS['read']) if @thread.status.follower_inbox == 2 && current_user != @thread.originator # he is looking @ his reply
    @thread.status.update_attribute(:follower_outbox, MessageStatus::STATUS['read']) if @thread.status.follower_outbox == 2
    # find all messages of thread
    @messages = Message.find(:all, :conditions => ['thread_id = ?', @thread.id], :order => 'created_at')
  end
  
  # delete the selected thread from the respective user's view
  def destroy
    thread = Message.find(params[:id])
    user = (thread.originator == current_user ? 'originator' : 'follower')
    thread.status.update_attribute("#{user}_#{params[:location]}".to_sym, MessageStatus::STATUS['deleted'])
    redirect_to :action => params[:location]
  end

end