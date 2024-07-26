class ReprocessPsusJob < ApplicationJob
  UNWANTED_EFFICIENCIES = ['SILVER']
  MINIMUM_WATTAGE       = 1200
  MAXIMUM_WATTAGE       = 2000

  queue_as :default

  CYBENETICS_PSU_URL = "https://www.cybenetics.com/index.php?option=power-supplies"
  SKIPPED_BRANDS     =
    [
      '1ST PLAYER',
      'ABYSM GAMING',
      'AEROCOOL',
      'APEXGAMING',
      'AQIRYS',
      'ARESGAME',
      'BITFENIX',
      'CASECOM',
      'CHANNEL WELL TECHNOLOGY',
      'CHIEFTEC',
      'CHIEFTRONIC',
      'COUGAR',
      'DUEX',
      'FRACTAL DESIGN',
      'GALAX',
      'GAME G FACTOR',
      'GAMEMAX',
      'GIGABYTE',
      'GREEN MEDEL',
      'HIGH POWER',
      'HUSKY',
      'INWIN',
      'KBM! GAMING',
      'KINPOWER',
      'KOLINK',
      'MAXPOWER',
      'MICRONICS',
      'MISTEL',
      'MONTECH',
      'MSI',
      'PC POWER & COOLING',
      'PCCOOLER',
      'PCYES',
      'PICHAU GAMING',
      'POWERSPEC',
      'RAIJINTEK',
      'RIOTORO',
      'ROSEWILL',
      'SALCOMP',
      'SAMA',
      'SEGOTEP',
      'SHARKOON',
      'SUPERFRAME',
      'THERMALRIGHT',
      'THERMALTAKE',
      'VETROO',
      'WENTAI',
      'XPG',
      'ZALMAN',
      'ZHONG YUAN POWER'
    ]
  ALWAYS_ADD_MODEL   = [
    'C1500 Platinum'
  ]
  ALWAYS_SKIP_MODEL  = [
    'RM1000x (Shift)',
    'MWE Gold 1050W V2 ATX 3.1'
  ]

  PSU     = Struct.new(
    *PowerSupply.column_names.map(&:to_sym) - [:id, :created_at, :updated_at]
  )
  PSUS    = {}
  ATX_MAP = {
    # 'ETA & LAMBDA 230V' => 'ATX',
    'ATX V3.0 230V' => 'ATX 3.0',
    'ATX V3.1 230V' => 'ATX 3.1',
  }

  def perform(args = {})
    @allow_a_minus     = args[:allow_a_minus].present?
    @all_brands        = args[:all_brands].present?
    @all_noise_ratings = args[:all_noise_ratings].present?

    manufacturer = args[:manufacturer] || :all
    start_time   = Time.now
    @logger      = Logger.new(STDOUT)
    sql_options  = if manufacturer == :all
                     {}
                   else
                     { manufacturer: manufacturer }
                   end

    begin

      PowerSupply.where(sql_options).delete_all
      @options = Selenium::WebDriver::Chrome::Options.new
      @options.add_argument("--headless")
      @options.add_argument("--headless=new")
      if Rails.env.production?
        Selenium::WebDriver::Chrome.driver_path = 'chromedriver'
      end
      @driver = Selenium::WebDriver.for :chrome, options: @options

      async_message 'Start'

      manufacturer_links.keys.each do |link|
        @manufacturer = @manufacturer_links[link]

        case manufacturer
        when :all
          if viable_manufacturer?
            add_for_manufacturer(link)
          end
        when @manufacturer
          add_for_manufacturer(link)
        else
          async_message "Skipping manufacturer #{@manufacturer}"
        end
      end

      PSUS.values.each do |data|
        PowerSupply.create(data.to_h)
      end

      end_time = Time.now
      duration = end_time - start_time
      async_message "Finished in #{duration} ms"

      async_redirect
    ensure
      async_message 'End'
      @driver.quit
    end
  end

  private

  def async_message(message)
    # @logger.info message

    ActionCable.server.broadcast(
      'all',
      {
        head: 200,
        notice: true,
        message: message
      }
    )
  end

  def async_redirect
    ActionCable.server.broadcast(
      'all',
      {
        head: 302,
        path: Rails.application.routes.url_helpers.power_supplies_path
      }
    )
  end

  def manufacturer_links
    async_message 'Getting manufacturer links'

    @manufacturer_links = {}
    @driver.navigate.to CYBENETICS_PSU_URL
    elements = @driver.find_elements(:css, '#myTable th a')
    elements.each { |e| @manufacturer_links[e.attribute(:href)] = e.text }

    @manufacturer_links.each do |link|
      async_message "found link: #{link}}"
    end

    @manufacturer_links.except!(@manufacturer_links.keys.last)
  end

  def add_for_manufacturer(link)
    @driver.navigate.to link
    async_message "_" * 50
    async_message "For brand: #{@manufacturer_links[link]}"

    ATX_MAP.each do |k, v|
      async_message "Processing #{@manufacturer_links[link]} - #{v}"
      add_all_for(k, v)
    end
  end

  def add_all_for(button_text, atx_version)
    sleep 2
    button = @driver.find_element(link_text: button_text)
    button.click
    sleep 2

    nodisp = @driver.find_elements(:css, '.d-none')
    nodisp.each do |element|
      @driver.execute_script("arguments[0].setAttribute('class', 'sm')", element)
    end

    trs = @driver.find_elements(:css, '#myTable tr')[3..-1]
    if trs
      trs.each do |tr|
        data = tr.find_elements(:tag_name, "td").map(&:text)[0..-3]
        if viable?(data) || always_add_model?(data)
          async_message "Got #{@manufacturer} - #{data.first}"
          attrs = data + [@manufacturer, atx_version]
          PSUS.update(attrs.first => PSU.new(*attrs))
        end
      end
    end
  rescue
    nil
  end

  def viable?(data)
    data.present? && !data[1].start_with?('SFX') &&
      !UNWANTED_EFFICIENCIES.include?(data[8]) &&
      data[2].to_i.between?(MINIMUM_WATTAGE, MAXIMUM_WATTAGE) &&
      !skipped_expensive_models.include?(data[0]) &&
      !ALWAYS_SKIP_MODEL.include?(data[0]) &&
      noise_rating_filter(data) && a_minus_filter(data)
  end

  def a_minus_filter(data)
    if @allow_a_minus
      true
    else
      data[9] != 'A-'
    end
  end

  def noise_rating_filter(data)
    if @all_noise_ratings
      true
    else
      data[9].start_with?('A')
    end
  end

  def always_add_model?(data)
    data.present? && ALWAYS_ADD_MODEL.include?(data[0])
  end

  def skipped_expensive_models
    metadata_records          = PsuMetadata.where('price > 350')
    @skipped_expensive_models ||= metadata_records.map(&:model)
  end

  def viable_manufacturer?
    @all_brands || !SKIPPED_BRANDS.include?(@manufacturer)
  end
end
