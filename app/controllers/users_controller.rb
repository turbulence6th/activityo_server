class UsersController < ApplicationController
 
  def callback
    respond_to do |format|
        format.json { render :json => { } }
      end
  end
  
  def loginFacebook
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://graph.facebook.com/me?" +
    "fields=id,name,email,gender,birthday,education,likes,picture&access_token=" + params[:access_token])))

    user = User.find_by(:facebookID => userParams['id'])
    
    if user
      Session.where(:deviceId => params[:deviceId]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :pushToken => params[:pushToken],
       :deviceId => params[:deviceId], :deviceType => params[:deviceType])
      user.sessions << session
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token } }
      end
    elsif userParams['id']
      education = userParams['education'][-1]['school']['name'] if userParams['education']
      user = User.create(:name => userParams['name'], :email => userParams['email'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :education => education, :role => 'member', :facebookID => userParams['id'],
        :deleted => false)
     
      imageUrl = "https://graph.facebook.com/#{userParams['id']}/picture?height=400&width=400"
      user.image = Image.new(:imagefile => URI.parse(imageUrl))
      
      Session.where(:deviceId => params[:deviceId]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :pushToken => params[:pushToken],
       :deviceId => params[:deviceId], :deviceType => params[:deviceType])
      user.sessions << session
  
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token } }
      end 
         
      Thread.new do
        if userParams['likes']
          likes = userParams['likes']
  
          while likes do
            likes['data'].each do |like|
              myLike = Like.create_with(:name => like['name']).find_or_create_by(:likeID => like['id'])
              user.likes << myLike
            end

          if likes['paging']['next']
            likes = JSON.parse(Net::HTTP.get(URI.parse(likes['paging']['next'])))
          else
            likes = nil
          end
        end
      end
     end
     
    else
      respond_to do |format|
        format.json { render :json => { :auth_token => nil } }
      end
    end
  end
  
  def loginGoogle
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://www.googleapis.com/plus/v1/people/me?access_token=" +
     params[:access_token])))
    
    user = User.find_by(:googleID => userParams['id'])
    
    if user
      Session.where(:deviceId => params[:deviceId]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :pushToken => params[:pushToken],
       :deviceId => params[:deviceId], :deviceType => params[:deviceType])
      user.sessions << session
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token} }
      end
    elsif userParams['id']
      user = User.create(:name => userParams['displayName'], :email => userParams['emails'][0]['value'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :googleID => userParams['id'],
        :deleted => false)
      Session.where(:deviceId => params[:deviceId]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :pushToken => params[:pushToken],
       :deviceId => params[:deviceId], :deviceType => params[:deviceType])
      user.sessions << session
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :auth_token => nil } }
      end
    end
  end
  
  def logout
    @session.destroy
    respond_to do |format|
      format.json { render :json => { :success=> true } }
    end
  end
  
  def send_message
    type = params['type']
    if type == 'User'
      receiver = User.find_by(:id => params[:id])
      message = Message.new(:to => receiver, :text => params[:text])
      @user.message_send << message
      message = message.as_json.merge!(:image => URI.join(request.url, 
          @user.get_image.imagefile.url).to_s, :name => @user.name)
      Thread.new do
        send_notification_message_user(receiver, message).body
      end
    elsif type == 'Event'
      receiver = Event.find_by(:id => params[:id])
      if Join.exists?(:event => receiver, :user => @user, :allowed => true)
        message = Message.new(:to => receiver, :text => params[:text])
        @user.message_send << message
        message = message.as_json.merge!(:image => URI.join(request.url, 
            @user.get_image.imagefile.url).to_s, :name => @user.name )
        Thread.new do
          send_notification_message_event(receiver, message)
        end
      end
    end
  
    respond_to do |format|
      format.json { render :json => { :message => message } }
    end
  end
  
  def getmessages
    messages = ActiveRecord::Base.connection.
      execute("SELECT message.sender_id, message.to_type as type, message.name, " +
        "MAX(message.created_at) as created_at FROM (SELECT messages.to_id as sender_id, " +
        "messages.to_type, events.name, messages.created_at FROM messages, joins, events " +
        "WHERE messages.to_type='Event' AND messages.to_id=events.id AND " +
        "events.id=joins.event_id AND joins.user_id=#{@user.id} AND joins.allowed=true UNION " +
        "SELECT messages.from_id as sender_id, messages.to_type, users.name, messages.created_at " +
        "FROM messages, users WHERE messages.to_type='User' AND messages.from_id=users.id AND " +
        "messages.to_id=#{@user.id} UNION SELECT messages.to_id as sender_id, messages.to_type, "+
        "users.name, messages.created_at FROM messages, users WHERE messages.to_type='User' " + 
        "AND messages.from_id=#{@user.id} AND messages.to_id=users.id) as message " +
        "GROUP BY message.sender_id, message.to_type, message.name ORDER BY created_at DESC")
        
    messagesResponse = []
    messages.each do |m|
      if m['type'] == 'User'
        image = Image.find_by(:imageable_id => m['sender_id'], 
          :imageable_type => 'User') || Image.new
        messagesResponse << m.as_json.merge!(:image => URI.join(request.url, 
          image.imagefile.url).to_s )
      else
        messagesResponse << m.as_json.merge!(:image => 
          Event.find_by(:id => m['sender_id']).eventType )
      end
    end  
    
    respond_to do |format|
      format.json { render :json => { :messages => messagesResponse } }
    end
  end
  
  def showMessage
    begin
      Integer(params[:id])
      Integer(params[:len])
    rescue
      return
    end
    type = params[:type]
    if type == 'User'
      user = User.find_by(:id => params[:id])
      messageList = ActiveRecord::Base.connection.
        execute("SELECT messages.*, users.id as user_id, users.name " +
          "FROM messages, users " +
          "WHERE messages.to_type='User' AND users.id=messages.from_id AND ((messages.from_id=#{user.id} AND " + 
          "messages.to_id=#{@user.id}) OR (messages.from_id=#{@user.id} AND " + 
          "messages.to_id=#{user.id})) ORDER BY messages.created_at DESC " +
          "OFFSET #{params[:len]} LIMIT 20")
    elsif type == 'Event'
      event = Event.find_by(:id => params[:id])
      if Join.exists?(:event => event, :user => @user, :allowed => true)
        messageList = ActiveRecord::Base.connection.
          execute("SELECT messages.*, users.id as user_id, users.name " + 
            "FROM messages, users " + 
            "WHERE users.id=messages.from_id AND " +
              "messages.to_type='Event' AND " +
              "messages.to_id=#{params[:id]} " +
              "ORDER BY messages.created_at DESC " +
              "OFFSET #{params[:len]} LIMIT 20")
      end
    end
    
    responseMessageList = []
    messageList.each do |m|
      image = Image.find_by(:imageable_id => m['user_id'], 
        :imageable_type => 'User') || Image.new
      responseMessageList << m.as_json.merge!("image" => URI.join(request.url, 
        image.imagefile.url).to_s )
    end
    
    respond_to do |format|
      format.json { render :json => { :user => @user, :messageList => responseMessageList } }
    end
  end
  
  def getUserInfo
    
    if !params[:user_id] || @user.id.to_s == params[:user_id]
      user = @user
    else
      user = User.find_by(:id => params[:user_id])
      friendUser = Friend.find_by('(user_1_id=? AND user_2_id=?) OR (user_1_id=? AND user_2_id=?)',
       @user.id, user.id, user.id, @user.id)
      if !friendUser
        friendStatus = 1
      elsif !friendUser.accepted && friendUser.user_1_id == @user.id
        friendStatus = 2
      elsif !friendUser.accepted && friendUser.user_1_id == user.id
        friendStatus = 3
      else
        friendStatus = 4
      end
      referenced = Reference.exists?(:from => @user, :to => user)
    end
    
    events = Event.from('events, joins').where('joins.event_id=events.id and joins.user_id=? and joins.allowed=true', user.id)
      .order('created_at desc').limit(3)
   
    references = ActiveRecord::Base.connection.
      execute("select users.id, users.name, #{'"references"'}.text, #{'"references"'}.created_at from users, #{'"references"'} " +
       "where users.id=#{'"references"'}.from_id and #{'"references"'}.to_id=#{user.id} " + 
       "order by #{'"references"'}.created_at desc limit 3")
    referencesResponse = []
    references.each do |ref|
      image = Image.find_by(:imageable_id => ref['id'], 
        :imageable_type => 'User') || Image.new
      referencesResponse << ref.as_json.merge!("image" => URI.join(request.url, 
        image.imagefile.url).to_s )
    end
    
    friends = user.friends.order('RANDOM()').limit(10)
    friendsResponse = []
    friends.each do |friend|
      friendsResponse << friend.as_json.merge!(:image => URI.join(request.url, 
        friend.get_image.imagefile.url).to_s )
    end
    
    respond_to do |format|
      format.json { render :json => {:user => user, 
        :events => events, 
        :references => referencesResponse, 
        :friends => friendsResponse,
        :image => URI.join(request.url, user.get_image.imagefile.url).to_s,
        :friendStatus => friendStatus,
        :referenced => referenced } }
    end

  end
  
  def getUserEvents
    user = User.find_by(:id => params[:user_id])
    events = Event.from('events, joins').where('joins.event_id=events.id and joins.user_id=? and joins.allowed=true', user.id)
      .order('created_at desc')
    respond_to do |format|
      format.json { render :json => {:user => user, 
        :events => events } }
    end
  end
  
  def beReference
    referenced_to = User.find_by(:id => params['user_id'])
    reference = Reference.new(:from => @user,:to => referenced_to, :text => params['text'])
    if reference.save
      respond_to do |format|
        format.json { render :json => {:success => true} }
      end
    else
      respond_to do |format|
        format.json { render :json => {:success => false} }
      end
    end
    
  end
  
  def findUser
    users = User.where('name ILIKE ?', "%#{params[:name]}%")
    usersResponse = []
    users.each do |user|
      usersResponse << user.as_json.merge!(:image => URI.join(request.url, 
        user.get_image.imagefile.url).to_s )
    end

    respond_to do |format|
      format.json { render :json => {:users => usersResponse } }
    end
  end
  
  def addFriend
    friendUser = User.find_by(:id => params[:user_id])
    friend = Friend.new(:user_1 => @user, :user_2 => friendUser, :accepted => false)
    if friend.save
      Thread.new do
        send_notification_add_friend(friendUser)
      end
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false, :errors => friend.errors } }
      end
    end
  end
  
  def acceptRequest
    friendUser = User.find_by(:id => params[:user_id])
    friend = Friend.find_by(:user_1 => friendUser, :user_2 => @user, :accepted => false)
    if friend
      friend.update_attributes(:accepted => true)
      Thread.new do
        send_notification_accept_friend(friendUser)
      end
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def deleteRequest
    friendUser = User.find_by(:id => params[:user_id])
    friend = Friend.find_by(:user_1 => friendUser, :user_2 => @user, :accepted => false)
    if friend
      friend.destroy
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def cancelRequest
    friendUser = User.find_by(:id => params[:user_id])
    friend = Friend.find_by(:user_1 => @user, :user_2 => friendUser, :accepted => false)
    if friend
      friend.destroy
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def deleteFriend
    friendUser = User.find_by(:id => params[:user_id])
    friend = Friend.find_by("((user_1_id=? AND user_2_id=?) OR (user_1_id=? AND user_2_id=?)) AND accepted=true", 
      @user.id, friendUser.id, friendUser.id, @user.id)
    if friend
      friend.destroy
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def friendRequestUsers
    users = User.from('friends, users')
      .where('friends.user_2_id=? AND friends.accepted=false AND users.id=friends.user_1_id', @user.id)
    usersResponse = []
    users.each do |user|
      usersResponse << user.as_json.merge!(:image => URI.join(request.url, 
        user.get_image.imagefile.url).to_s )
    end
    respond_to do |format|
        format.json { render :json => { :friendRequestUsers => usersResponse } }
     end
  end
  
  def getBasicInfo
    respond_to do |format|
        format.json { render :json => { :user => @user,  :image => URI.join(request.url, 
        @user.get_image.imagefile.url).to_s} }
     end
  end
  
end
