class RegistrationsController < ApplicationController
  before_action :find_event
  before_action :set_pending_registration, :only => [:step1, :step1_update, :step2, :step2_update, :step3, :step3_update]

  def new
  end

  def step1
    # @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step1_update
    # @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.current_step = 1

    if @registration.update(registration_params)
      redirect_to step2_event_registration_path(@event, @registration)
    else
      render "step1"
    end
  end

  def step2
    # @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step2_update
    # @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.current_step = 2

    if @registration.update(registration_params)
      redirect_to step3_event_registration_path(@event, @registration)
    else
      render "step2"
      end
  end

  def step3
    # @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step3_update
    # @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.status = "confirmed"
    @registration.current_step = 3

    # NotificationMailer.confirmed_registration( Registration.by_status("confirmed").last ).deliver_now
    NotificationMailer.confirmed_registration(@registration).deliver_later

    if @registration.update(registration_params)
      flash[:notice] = "報名成功" 
      redirect_to event_registration_path(@event, @registration)
    else
      render "step3"
    end
  end

  def create
    @registration = @event.registrations.new(registration_params)
    @registration.ticket = @event.tickets.find( params[:registration][:ticket_id] )
    # @registration.status = "confirmed"
    @registration.status = "pending"
    @registration.user = current_user
    @registration.current_step = 1

    if @registration.save
      CheckRegistrationJob.set( wait: 15.minutes ).perform_later(@registration.id)
      # redirect_to event_registration_path(@event, @registration)
      redirect_to step2_event_registration_path(@event, @registration)
    else
      flash.now[:alert] = @registration.errors[:base].join("、")
      render "new"
    end
  end

  def show
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  protected

  def registration_params
    params.require(:registration).permit(:ticket_id, :name, :email, :cellphone, :website, :bio)
  end

  def find_event
    @event = Event.find_by_friendly_id(params[:event_id])
  end

  def set_pending_registration
    @registration = @event.registrations.find_by_uuid(params[:id])

    if @registration.status == "cancalled"
      flash[:alert] = "請重新報名"
      redirect_to event_path(@event)
    end
  end
end
