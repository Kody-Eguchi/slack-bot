class IncidentsController < ApplicationController
  before_action :set_incident, only: %i[ show edit update destroy ]

  # GET /incidents or /incidents.json
  def index
    @incidents = Incident.all

    direction = params[:direction] == "desc" ? "desc" : "asc"

    case params[:sort]
    when "created_at"
      @incidents = @incidents.order(created_at: direction)
    when "title"
      @incidents = @incidents.order(title: direction)
    else
      @incidents = @incidents.order(created_at: :desc) #
    end
  end

  # GET /incidents/1 or /incidents/1.json
  def show
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
  end

  # GET /incidents/1/edit
  def edit
  end

  # POST /incidents or /incidents.json
  def create
    @incident = Incident.new(incident_params)

    respond_to do |format|
      if @incident.save
        format.html { redirect_to @incident, notice: "Incident was successfully created." }
        format.json { render :show, status: :created, location: @incident }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incidents/1 or /incidents/1.json
  def update
    respond_to do |format|
      if @incident.update(incident_params)
        format.html { redirect_to @incident, notice: "Incident was successfully updated." }
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incidents/1 or /incidents/1.json
  def destroy
    @incident.destroy!

    respond_to do |format|
      format.html { redirect_to incidents_path, status: :see_other, notice: "Incident was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incident
      @incident = Incident.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def incident_params
      params.require(:incident).permit(
        :title,
        :description,
        :severity,
        :status,
        :creator,
        :slack_channel_id,
        :resolved_at
      )
    end
end
