class EventsController < ApplicationController
  
  def getEvents
    
    events = Event.near([params[:lat], params[:long]], 10000, :order => "distance")
        .offset(params[:len]).limit(10)
        
    if params[:eventType] != ""
      events = events.where(:eventType => Event.eventTypes[params[:eventType]]) 
    end  
      
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
    user = event.user
    respond_to do |format|
      format.json { render :json => { :event => event, :user => user } }
    end
  end
  
  def event_params
    params.require(:event).permit(:name, :eventType, :startDate, :description, :address)
  end
  
end
