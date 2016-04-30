class EventsController < ApplicationController
  
  def getEvents
    events = Event.near([params[:lat], params[:long]], params[:distance], :order => "distance")
        .offset(params[:len]).limit(12)
    eventTypes = params[:eventTypes]
    eventTypeParams = []
    eventTypes.each do |type|
      if type['checked'] == 'true' || type['checked'] == true
        eventTypeParams << Event.eventTypes[type['value']]
      end
    end
    events = events.where(:eventType => eventTypeParams)
    events = events.where("name ILIKE ?", "%#{params[:eventName]}%")
    
    eventsResponse = []
    events.each do |e|
      image = Image.find_by(:imageable_id => e.user_id, 
        :imageable_type => 'User') || Image.new
      eventsResponse << e.as_json.merge!(:image => URI.join(request.url, 
        image.imagefile.url).to_s )
    end
    
    respond_to do |format|
      format.json { render :json => { :events => eventsResponse } }
    end
  end
  
  def createEvent
    event = Event.new(event_params)
    event.user = @user
    event.startDate = event.startDate - 3.hours
    
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
      .order('RANDOM()').limit(10)
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
      Thread.new do
        send_notification_request(event.user, event)
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
  
  def acceptEventRequest
    event = Event.find_by(:id => params[:event_id], :user => @user)
    user = User.find_by(:id => params[:user_id])
    join = Join.find_by(:event => event, :user => user, :allowed => false)
    if join
      join.update_attributes(:allowed => true)
      Thread.new do
        send_notification_accept_request(user, event)
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
  
  def rejectEventRequest
    event = Event.find_by(:id => params[:event_id], :user => @user)
    user = User.find_by(:id => params[:user_id])
    join = Join.find_by(:event => event, :user => user, :allowed => false)
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
  
  def eventRequestUsers
    userEvent= ActiveRecord::Base.connection.
      execute("select users.id as user_id, users.name as user_name, " + 
      "events.id as event_id, events.name as event_name from joins, users, events " +
      "where events.user_id=#{@user.id} AND joins.event_id=events.id AND joins.user_id=users.id " + 
      "AND joins.allowed=false")
    userEventResponse = []
    userEvent.each_with_index do |row, index|
      image = Image.find_by(:imageable_id => row['user_id'], 
        :imageable_type => 'User') || Image.new
      userEventResponse << row.merge!(:image => URI.join(request.url, 
        image.imagefile.url).to_s, :index => index)
    end
    respond_to do |format|
      format.json { render :json => { :eventRequestUsers => userEventResponse } }
    end
  end
  
  def event_params
    params.require(:event).permit(:name, :eventType, :startDate, :description, :address,
      :longitude, :latitude)
  end
  
end
