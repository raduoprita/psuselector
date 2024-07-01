class PowerSuppliesController < ApplicationController
  before_action :set_power_supply, only: %i[ show edit update destroy ]

  PSU     = Struct.new(
    *PowerSupply.column_names.map(&:to_sym) - [:id, :created_at, :updated_at]
  )
  PSUS    = []
  ATX_MAP = {
    # 'ATX V3.1 230V'     => 'ATX 3.1',
    # 'ATX V3.0 230V'     => 'ATX 3.0',
    'ETA & LAMBDA 230V' => 'ATX'
  }

  # GET /power_supplies or /power_supplies.json
  def index
    @power_supplies = PowerSupply.all
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
        format.html { redirect_to power_supply_url(@power_supply), notice: "Power supply was successfully updated." }
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
    redirect_to power_supplies_path
  end
  
  def reprocess2
    @cybenetics_base_url = 'https://www.cybenetics.com/'
    @cybenetics_psu_url  = "#{@cybenetics_base_url}index.php?option=power-supplies"

    PowerSupply.delete_all

    @options = Selenium::WebDriver::Chrome::Options.new
    @options.add_argument("--headless")

    temp_key = manufacturer_links.keys.first
    add_for_manufaturer(temp_key)

    # manufacturer_links.keys.each do |link|
    #   add_for_manufaturer(link)
    # end

    redirect_to power_supplies_path
  end

  private

  def manufacturer_links
    @manufacturer_links = {}
    begin
      driver = Selenium::WebDriver.for :chrome, options: @options
      driver.navigate.to @cybenetics_psu_url
      elements = driver.find_elements(:css, '#myTable th a')
      elements.each { |e| @manufacturer_links[e.attribute(:href)] = e.text }
    ensure
      driver.quit
    end
    @manufacturer_links.except!(@manufacturer_links.keys.last)
  end

  def add_for_manufaturer(link)
    begin
      driver = Selenium::WebDriver.for :chrome, options: @options
      driver.navigate.to link

      ATX_MAP.each do |k,v|
        sleep 5
        add_all_for(driver, link, k, v)
      end
    ensure
      driver.quit
    end
  end

  def add_all_for(driver, link, button_text, atx_version)
    button = driver.find_element(link_text: button_text)
    button.click
    sleep 5
    trs = driver.find_elements(:css, '#myTable tr')
    trs.shift(3).each do |tr|
      data = tr.find_elements(:tag_name, "td").map(&:text)[0..-3]

      # TODO check if exists, only add if not

      attrs = data + [@manufacturer_links[link], atx_version]
      PSUS << PSU.new(*attrs)
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_power_supply
    @power_supply = PowerSupply.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def power_supply_params
    params.require(:power_supply).permit(:manufacturer, :model, :atx_version, :form_factor, :wattage, :avg_efficiency, :avg_efficiency_5vsb, :vampire_power, :avg_pf, :avg_noise, :efficiency_rating, :noise_rating, :release_date)
  end
end
