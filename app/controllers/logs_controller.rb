class LogsController < ApplicationController
  before_action :set_log, only: [:show]

  # GET /logs
  # GET /logs.json
  def index
    @passes = Log.where(error: false)
    @errors = Log.where(error: true)
  end

  # GET /logs/1
  # GET /logs/1.json
  def show
    #@log = Log.find(params[:log_id])
    @data = File.read(@log.log_path)
  end

  # GET /logs/new
  def new
    @log = Log.new
  end

  # GET /logs/1/edit
  def edit
  end

  # POST /logs
  # POST /logs.json
  def create
    @log = Log.new(log_params)

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: 'Log was successfully created.' }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
  def update
    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: 'Log was successfully updated.' }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to logs_url, notice: 'Log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def system_log
    @data = File.read("#{Rails.root}/log/knife/system.log")
  end

  def clear_system_log
    File.open("#{Rails.root}/log/knife/system.log", "w") {}
    flash[:success] = "system.log was successfully cleared"
    redirect_to logs_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = Log.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def log_params
      params.require(:log).permit(:log_path, :error)
    end
end
