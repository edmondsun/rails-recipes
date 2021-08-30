# require 'axlsx'
require 'csv'

class Admin::EventRegistrationsController < AdminController
  before_action :find_event
  before_action :require_editor!

  def index
    # @registrations = @event.registrations.includes(:ticket).order("id DESC")
    # @registrations = @event.registrations.includes(:ticket).order("id DESC").page(params[:page]).per(10)
    @q = @event.registrations.ransack(params[:q])
    @registrations = @q.result.includes(:ticket).order("id DESC").page(params[:page]).per(10)

    if params[:registration_id].present?
      @registrations = @registrations.where( :id => params[:registration_id].split(",") )
    end

    if params[:start_on].present?
     @registrations = @registrations.where( "created_at >= ?", Date.parse(params[:start_on]).beginning_of_day )
    end

    if params[:end_on].present?
     @registrations = @registrations.where( "created_at <= ?", Date.parse(params[:end_on]).end_of_day )
    end

    if params[:status].present? && Registration::STATUS.include?(params[:status])
     @registrations = @registrations.by_status(params[:status])
    end

    if params[:ticket_id].present?
     @registrations = @registrations.by_ticket(params[:ticket_id])
    end

    if Array(params[:statuses]).any?
     @registrations = @registrations.by_status(params[:statuses])
    end

    if Array(params[:ticket_ids]).any?
     @registrations = @registrations.by_ticket(params[:ticket_ids])
    end

    begin
      # respond_to do |format|
      #   p = Axlsx::Package.new
      #   wb = p.workbook
        
      #   # @registrations = @event.registrations.reorder("id ASC")
      #   @registrations = @registrations.reorder("id ASC")

      #   # wb.add_worksheet(name: "報名冊錄") do |sheet|
      #   wb.add_worksheet(name: "report") do |sheet|
      #     sheet.add_row(["報名ID", "票種", "姓名", "狀態", "Email", "報名時間"])
      #     @registrations.each do |r|
      #       sheet.add_row([r.id, r.ticket.name, r.name, t(r.status, :scope => "registration.status"), r.email, r.created_at])
      #     end
      #   end

      #   p.use_autowidth = false

      #   byebug

      #   format.html
      #   format.xlsx {
      #     send_data p.to_stream.read, type: "application/xlsx", filename: "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.xlsx"
      #     # send_data p.to_stream.read, type: "application/xlsx", filename => "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.xlsx"
      #   }
      # end
      respond_to do |format|
        format.html
        format.csv {
          @registrations = @registrations.reorder("id ASC")
          csv_string = CSV.generate do |csv|
            csv << ["報名ID", "票種", "姓名", "狀態", "Email", "報名時間"]
            @registrations.each do |r|
              csv << [r.id, r.ticket.name, r.name, t(r.status, :scope => "registration.status"), r.email, r.created_at]
            end
          end
          send_data csv_string, :filename => "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.csv"
        }
        format.xlsx
      end
    rescue Exception => e
      render json: {success: false, message: "export user error: #{e.to_s}"}
    end
  end

  def new
    @registration = @event.registrations.new
  end

  def edit
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def destroy
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.destroy
    redirect_to admin_event_registrations_path(@event)
  end

  def create
    @registration = @event.registrations.new(registration_params)
    if @registration.save
      redirect_to admin_event_registrations_path(@event)
    else
      render "new"
    end
  end

  def update
    @registration = @event.registrations.find_by_uuid(params[:id])

    if @registration.update(registration_params)
      redirect_to admin_event_registrations_path(@event)
    else
      render "edit"
    end
  end

  # def download_xlsx
  #   byebug
  #   begin
  #     respond_to do |format|
  #       p = Axlsx::Package.new
  #       wb = p.workbook
  #       @registrations = @event.registrations.reorder("id ASC")

  #       wb.add_worksheet(name: "報名冊錄") do |sheet|
  #         sheet.add_row(["報名ID", "票種", "姓名", "狀態", "Email", "報名時間"])
  #         @registrations.each do |r|
  #           sheet.add_row([r.id, r.ticket.name, r.name, t(r.status, :scope => "registration.status"), r.email, r.created_at])
  #         end
  #       end

  #       p.use_autowidth = false

  #       format.html
  #       format.xlsx {
  #         send_data p.to_stream_read, type: "application/xlsx", filename => "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.xlsx"
  #       }
  #     end
  #   rescue Exception => e
  #     render json: {success: false, message: "export user error: #{e.to_s}"}
  #   end
  # end

  def import
    csv_string = params[:csv_file].read.force_encoding('utf-8')

    tickets = @event.tickets

    success = 0
    failed_records = []

    CSV.parse(csv_string) do |row|
      registration = @event.registrations.new( :status => "confirmed",
                                   :ticket => tickets.find{ |t| t.name == row[0] },
                                   :name => row[1],
                                   :email => row[2],
                                   :cellphone => row[3],
                                   :website => row[4],
                                   :bio => row[5],
                                   :created_at => Time.parse(row[6]) )

      if registration.save
        success += 1
      else
        failed_records << [row, registration]
        Rails.logger.info("#{row} ----> #{registration.errors.full_messages}")
      end
    end

    flash[:notice] = "總共匯入 #{success} 筆，失敗 #{failed_records.size} 筆"
    redirect_to admin_event_registrations_path(@event)
  end

  protected
  def find_event
    @event = Event.find_by_friendly_id!(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(:status, :ticket_id, :name, :email, :cellphone, :website, :bio)
  end
end
