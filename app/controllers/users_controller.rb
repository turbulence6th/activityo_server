class UsersController < ApplicationController
  
  def loginFacebook
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://graph.facebook.com/me?" +
    "fields=id,name,email,gender,birthday,education,likes&access_token=" + params[:access_token])))

    user = User.find_by(:facebookID => userParams['id'])

    if user
      respond_to do |format|
        format.json { render :json => { :auth_token => user.auth_token } }
      end
    elsif userParams['id']
      user = User.create(:name => userParams['name'], :email => userParams['email'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :facebookID => userParams['id'],
        :deleted => false, :auth_token => SecureRandom.uuid)
  
      user.education = userParams['education'][-1]['school']['name'] if userParams['education']
  
      respond_to do |format|
        format.json { render :json => { :auth_token => user.auth_token } }
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
      respond_to do |format|
        format.json { render :json => { :auth_token => user.auth_token } }
      end
    elsif userParams['id']
      user = User.create(:name => userParams['displayName'], :email => userParams['emails'][0]['value'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :googleID => userParams['id'],
        :deleted => false, :auth_token => SecureRandom.uuid)
      respond_to do |format|
        format.json { render :json => { :auth_token => user.auth_token } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :auth_token => nil } }
      end
    end
    facefa
  end
  
  def onesignal
    @user.update_attributes(:onesignal_token => params[:onesignal_token])
    respond_to do |format|
      format.json { render :json => { :success => true } }
    end
  end
  
  def send_message
    user_receiver = User.find_by(:id => params[:id])
    puts send_notification(user_receiver.onesignal_token, params[:text]).body
    message = Message.new(:to => user_receiver, :text => params[:text])
    @user.message_send << message
    respond_to do |format|
      format.json { render :json => { :message => message } }
    end
  end
  
  def getmessages
      users = User.select("users.id, users.name").from('users, messages')
        .where('messages.to_id=? AND messages.from_id=users.id', @user.id).distinct
    respond_to do |format|
      format.json { render :json => { :userList => users } }
    end
  end
  
  def showMessage
    message_user = User.select('users.id, users.name').find_by(:id => params[:id])
    messageList = Message.where('(to_id=? AND from_id=?) OR (to_id=? AND from_id=?)',
     @user.id, message_user.id, message_user.id, @user.id).order('created_at ASC')
     
    respond_to do |format|
      format.json { render :json => { :user => message_user, :messageList => messageList } }
    end
  end
  
  def getUserInfo
    
   events = Event.where(:user => @user)
   
   comments = ActiveRecord::Base.connection.
    execute("select users.name, comments.text, comments.created_at from users, comments where users.id=comments.from_id and comments.to_id=#{@user.id}")
    
   friends = @user.friends

    respond_to do |format|
      format.json { render :json => {:user => @user, :events => events, :comments => comments, :friends => friends } }
    end

  end
  
  def OtherUserInfo
    
   
    
    otherUser = User.find_by(:id => params[:id])
    
    events = Event.where(:user => otherUser)
    
    comments = ActiveRecord::Base.connection.
    execute("select users.name, comments.text, comments.created_at from users, comments where users.id=comments.from_id and comments.to_id=#{otherUser.id}")
    
    friends = other_user.friends

    respond_to do |format|
      format.json { render :json => {:user => other_user, :events => events, :comments => comments, :friends => friends } }
    end
    
    
  end
  

  
end
