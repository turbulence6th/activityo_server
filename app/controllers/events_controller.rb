class EventsController < ApplicationController
  
  def getEvents
    events = Event.near([params[:lat], params[:long]], params[:distance], :order => "distance")
        .offset(params[:len]).limit(10)
    eventTypes = params[:eventTypes]
    eventTypeParams = []
    eventTypes.each do |type|
      if type['checked'] == 'true'
        eventTypeParams << Event.eventTypes[type['value']]
      end
    end
    events = events.where(:eventType => eventTypeParams)
    events = events.where("name ILIKE ?", "%#{params[:eventName]}%")
    
    respond_to do |format|
      format.json { render :json => { :events => events } }
    end
  end
  
  def createEvent
    event = Event.new(event_params)
    event.user = @user
    if event.save
      Join.create(:event => event, :user => @user, :allowed => true)
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false, :errors => event.errors } }
      end
    end
  end
  
  def showEvent
    event = Event.find_by(:id => params[:id])
    createrUser = event.user
    joinUsers = User.select('users.*').from('users, joins')
      .where('joins.event_id=? AND joins.user_id=users.id AND joins.allowed=true', event.id)
    joinUsersResponse = []
    joinUsers.each do |user|
      joinUsersResponse << user.as_json.merge!(:image => URI.join(request.url, 
        user.get_image.imagefile.url).to_s )
    end
    
    join = Join.find_by(:event => event, :user => @user)
    if !join
      joinStatus = 1
    elsif !join.allowed
      joinStatus = 2
    elsif join.allowed
      joinStatus = 3
    end
    
    respond_to do |format|
      format.json { render :json => { :event => event, :user => createrUser, :joinUsers => joinUsersResponse,
        :joinStatus => joinStatus } }
    end
  end
  
  def joinEvent
    event = Event.find_by(:id => params[:event_id])
    join = Join.new(:event => event, :user => @user, :allowed => false)
    if join.save
      send_notification_request(event.user, event)
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def withdrawRequest
    event = Event.find_by(:id => params[:event_id])
    join = Join.find_by(:event => event, :user => @user)
    if join
      join.destroy
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def acceptRequest
    event = Event.find_by(:id => params[:event_id])
    user = User.find_by(:id => params[:user_id])
    join = Join.find_by(:event => event, :user => user)
    if join
      join.update_attributes(:allowed => true)
      send_notification_accept_request(user, event)
      respond_to do |format|
        format.json { render :json => { :success => true } }
      end
    else
      respond_to do |format|
        format.json { render :json => { :success => false } }
      end
    end
  end
  
  def event_params
    params.require(:event).permit(:name, :eventType, :startDate, :description, :address,
      :longitude, :latitude)
  end
  
end
