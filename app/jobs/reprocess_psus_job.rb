class ReprocessPsusJob < ApplicationJob
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
      'FRACTAL DESIGN',
      'GALAX',
      'GAME G FACTOR',
      'GAMEMAX',
      'GIGABYTE',
      'HIGH POWER',
      'INWIN',
      'KBM! GAMING',
      'KINPOWER',
      'KOLINK',
      'LIAN LI',
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
    @allow_a_minus = args[:allow_a_minus]
    @all_brands    = args[:all_brands]

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
      @driver = Selenium::WebDriver.for :chrome, options: @options

      @logger.info 'Start'

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
          @logger.info "Skipping manufacturer #{@manufacturer}"
        end
      end

      PSUS.values.each do |data|
        PowerSupply.create(data.to_h)
      end

      end_time = Time.now
      duration = end_time - start_time
      @logger.info("Finished in #{duration} ms")

      async_redirect
    ensure
      @logger.info 'End'
      @driver.quit
    end
  end

  private

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
    @logger.info 'Getting manufacturer links'

    @manufacturer_links = {}
    @driver.navigate.to CYBENETICS_PSU_URL
    elements = @driver.find_elements(:css, '#myTable th a')
    elements.each { |e| @manufacturer_links[e.attribute(:href)] = e.text }
    @manufacturer_links.except!(@manufacturer_links.keys.last)
  end

  def add_for_manufacturer(link)
    @driver.navigate.to link
    @logger.info("_" * 50)
    @logger.info "For brand: #{@manufacturer_links[link]}"

    ATX_MAP.each do |k, v|
      @logger.info "Processing #{v}"
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
    trs.each do |tr|
      data = tr.find_elements(:tag_name, "td").map(&:text)[0..-3]
      if viable?(data) || always_add_model?(data)
        @logger.info "Got #{@manufacturer} - #{data.first}"
        attrs = data + [@manufacturer, atx_version]
        PSUS.update(attrs.first => PSU.new(*attrs))
      end
    end
  end

  def viable?(data)
    data.present? && !data[1].start_with?('SFX') &&
      ['GOLD', 'PLATINUM', 'TITANIUM', 'DIAMOND'].include?(data[8]) &&
      data[2].to_i.between?(1000, 1500) &&
      !skipped_expensive_models.include?(data[0]) &&
      !ALWAYS_SKIP_MODEL.include?(data[0]) &&
      data[9].start_with?('A') && a_minus_filter(data)
  end

  def a_minus_filter(data)
    if @allow_a_minus
      true
    else
      data[9] != 'A-'
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
