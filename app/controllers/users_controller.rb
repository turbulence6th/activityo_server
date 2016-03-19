class UsersController < ApplicationController
  
  def loginFacebook
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://graph.facebook.com/me?" +
    "fields=id,name,email,gender,birthday,education,likes&access_token=" + params[:access_token])))

    user = User.find_by(:facebookID => userParams['id'])

    if user
      respond_to do |format|
        format.json { render :json => { :token => user.token } }
      end
    elsif userParams['id']
      user = User.create(:name => userParams['name'], :email => userParams['email'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :facebookID => userParams['id'],
        :deleted => false, :token => SecureRandom.uuid)
  
      user.education = userParams['education'][-1]['school']['name'] if userParams['education']
  
      respond_to do |format|
        format.json { render :json => { :token => user.token } }
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
        format.json { render :json => { :token => nil } }
      end
    end
  end
  
  def loginGoogle
    userParams = JSON.parse(Net::HTTP.get(URI.parse("https://www.googleapis.com/plus/v1/people/me?access_token=" +
     params[:access_token])))
    puts userParams
    
    user = User.find_by(:googleID => userParams['user_id'])
    
    if user
      respond_to do |format|
        format.json { render :json => { :token => user.token } }
      end
    elsif userParams['user_id']
      user = User.create(:name => userParams['displayName'], :email => userParams['emails'][0]['value'], :gender => userParams['gender'],
        :birthday => userParams['birthday'], :role => 'member', :googleID => userParams['user_id'],
        :deleted => false, :token => SecureRandom.uuid)
    else
      respond_to do |format|
        format.json { render :json => { :token => nil } }
      end
    end
    
  end
  
end
