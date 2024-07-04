class PowerSuppliesController < ApplicationController
  before_action :set_power_supply, only: %i[ show edit update destroy ]

  # GET /power_supplies or /power_supplies.json
  def index
    @order = 'avg_noise'
    @manufacturers = PowerSupply
                       .group(:manufacturer)
                       .order(:manufacturer)
                       .map(&:manufacturer)
    @power_supplies = PowerSupply.order(@order)
  end

  # GET /power_supplies/1 or /power_supplies/1.json
  def show
  end

  # GET /power_supplies/new
  def new
    @power_supply = PowerSupply.new
  end

  # GET /power_supplies/1/edit
  def edit
  end

  # POST /power_supplies or /power_supplies.json
  def create
    @power_supply = PowerSupply.new(power_supply_params)

    respond_to do |format|
      if @power_supply.save
        format.html { redirect_to power_supply_url(@power_supply), notice: "Power supply was successfully created." }
        format.json { render :show, status: :created, location: @power_supply }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @power_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /power_supplies/1 or /power_supplies/1.json
  def update
    respond_to do |format|
      if @power_supply.update(power_supply_params)
        format.html { redirect_to power_supplies_url, notice: "Power supply was successfully updated." }
        format.json { render :show, status: :ok, location: @power_supply }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @power_supply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /power_supplies/1 or /power_supplies/1.json
  def destroy
    @power_supply.destroy!

    respond_to do |format|
      format.html { redirect_to power_supplies_url, notice: "Power supply was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def reprocess
    ReprocessPsusJob.perform_later
    redirect_to power_supplies_url
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_power_supply
    @power_supply = PowerSupply.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def power_supply_params
    params.require(:power_supply).permit(:manufacturer, :model, :atx_version, :form_factor, :wattage, :avg_efficiency, :avg_efficiency_5vsb, :vampire_power, :avg_pf, :avg_noise, :efficiency_rating, :noise_rating, :release_date, :price)
  end
end
