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
    event.save
    respond_to do |format|
      format.json { render :json => { :errors => event.errors } }
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
    respond_to do |format|
      format.json { render :json => { :event => event, :user => createrUser, :joinUsers => joinUsersResponse } }
    end
  end
  
  def event_params
    params.require(:event).permit(:name, :eventType, :startDate, :description, :address,
      :longitude, :latitude)
  end
  
end
