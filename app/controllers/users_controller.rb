class UsersController < ApplicationController
  
  def loginFacebook
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://graph.facebook.com/me?" +
    "fields=id,name,email,gender,birthday,education,likes,picture&access_token=" + params[:access_token])))

    user = User.find_by(:facebookID => userParams['id'])
    
    if user
      Session.where(:onesignal_token => params[:onesignal_token]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :onesignal_token => params[:onesignal_token])
      user.sessions << session
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token, :user_id => user.id } }
      end
    elsif userParams['id']
      education = userParams['education'][-1]['school']['name'] if userParams['education']
      user = User.create(:name => userParams['name'], :email => userParams['email'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :education => education, :role => 'member', :facebookID => userParams['id'],
        :deleted => false)
     
      imageUrl = "https://graph.facebook.com/#{userParams['id']}/picture?type=large"
      user.image = Image.new(:imagefile => URI.parse(imageUrl))
      
      Session.where(:onesignal_token => params[:onesignal_token]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :onesignal_token => params[:onesignal_token])
      user.sessions << session
  
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token, :user_id => user.id } }
      end 
         
      thread = Thread.new do
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
      Session.where(:onesignal_token => params[:onesignal_token]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :onesignal_token => params[:onesignal_token])
      user.sessions << session
      respond_to do |format|
        format.json { render :json => { :auth_token => session.auth_token } }
      end
    elsif userParams['id']
      user = User.create(:name => userParams['displayName'], :email => userParams['emails'][0]['value'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :googleID => userParams['id'],
        :deleted => false)
      Session.where(:onesignal_token => params[:onesignal_token]).destroy_all
      session = Session.new(:auth_token => SecureRandom.uuid, :onesignal_token => params[:onesignal_token])
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
    user_receiver = User.find_by(:id => params[:id])
    message = Message.new(:to => user_receiver, :text => params[:text])
    @user.message_send << message
    send_notification_message_user(user_receiver, message)
    respond_to do |format|
      format.json { render :json => { :message => message } }
    end
  end
  
  def getmessages
    users = User.select("users.id, users.name").from('users, messages')
        .where("((messages.to_id=? AND messages.from_id=users.id) OR (messages.from_id=? AND messages.to_id=users.id)) AND (messages.to_type='User')", 
        @user.id, @user.id).distinct
    usersResponse = []
    users.each do |user|
      usersResponse << user.as_json.merge!(:image => URI.join(request.url, 
        user.get_image.imagefile.url).to_s )
    end
    respond_to do |format|
      format.json { render :json => { :userList => usersResponse } }
    end
  end
  
  def showMessage
    message_user = User.select('users.id, users.name').find_by(:id => params[:id])
    messageList = Message.where('(to_id=? AND from_id=?) OR (to_id=? AND from_id=?)',
     @user.id, message_user.id, message_user.id, @user.id).order('created_at DESC').offset(params[:len]).limit(40)
    respond_to do |format|
      format.json { render :json => { :user => message_user, :messageList => messageList } }
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
    end
    
    events = Event.where(:user => user)
   
    comments = ActiveRecord::Base.connection.
      execute("select users.name, comments.text, comments.created_at from users, comments where users.id=comments.from_id and comments.to_id=#{user.id}")
    
    friends = user.friends
    friendsResponse = []
    friends.each do |friend|
      friendsResponse << friend.as_json.merge!(:image => URI.join(request.url, 
        friend.get_image.imagefile.url).to_s )
    end
    
    respond_to do |format|
      format.json { render :json => {:user => user, 
        :events => events, 
        :comments => comments, 
        :friends => friendsResponse,
        :image => URI.join(request.url, user.get_image.imagefile.url).to_s,
        :friendStatus => friendStatus } }
    end

  end
  
  def SendComment
    commentText = params[:text]
    id = params[:id]
    comment = Comment.new(:from => @user,:to => id,:text => commentText)
    comment.save
    success = true
    respond_to do |format|
      format.json { render :json => success  }
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
      send_notification_add_friend(friendUser)
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
      send_notification_accept_friend(friendUser)
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
  
end
