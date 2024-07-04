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
      'MSI',
      'PC POWER & COOLING',
      'PCCOOLER',
      'PCYES',
      'PICHAU GAMING',
      'POWERSPEC',
      'RIOTORO',
      'ROSEWILL',
      'SALCOMP',
      'SAMA',
      'SEGOTEP',
      'SHARKOON',
      'SUPERFRAME',
      'VETROO',
      'WENTAI',
      'XPG',
      'ZALMAN',
      'ZHONG YUAN POWER',
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

  def perform
    start_time = Time.now
    @logger = Logger.new(STDOUT)

    begin
      PowerSupply.delete_all
      @options = Selenium::WebDriver::Chrome::Options.new
      @options.add_argument("--headless")
      @driver = Selenium::WebDriver.for :chrome, options: @options

      @logger.info 'Start'

      # temp_key = manufacturer_links.keys[7]
      # add_for_manufaturer(temp_key)

      manufacturer_links.keys.each do |link|
        @manufacturer = @manufacturer_links[link]

        unless not_wanted?(@manufacturer)
          add_for_manufaturer(link)
        end
      end

      PSUS.values.each do |data|
        PowerSupply.create(data.to_h)
      end

      end_time = Time.now
      duration = end_time - start_time
      @logger.info("Finished in #{duration} ms")
    ensure
      @logger.info 'End'
      @driver.quit
    end
  end

  private

  def manufacturer_links
    @logger.info 'Getting manufacturer links'

    @manufacturer_links = {}
    @driver.navigate.to CYBENETICS_PSU_URL
    elements = @driver.find_elements(:css, '#myTable th a')
    elements.each { |e| @manufacturer_links[e.attribute(:href)] = e.text }
    @manufacturer_links.except!(@manufacturer_links.keys.last)
  end

  def add_for_manufaturer(link)
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
    nodisp.each do |nodisp|
      @driver.execute_script("arguments[0].setAttribute('class', 'sm')", nodisp)
    end

    trs = @driver.find_elements(:css, '#myTable tr')[3..-1]
    trs.each do |tr|
      data = tr.find_elements(:tag_name, "td").map(&:text)[0..-3]
      if viable?(data)
        @logger.info "Got #{@manufacturer} - #{data.first}"
        attrs = data + [@manufacturer, atx_version]
        PSUS.update(attrs.first => PSU.new(*attrs))
      end
    end
  end

  def viable?(data)
    data.present? && !data[1].start_with?('SFX') &&
      ['GOLD', 'PLATINUM', 'TITANIUM', 'DIAMOND'].include?(data[8]) &&
      data[9].start_with?('A') && data[9] != 'A-' &&
      data[2].to_i >= 1000
  end

  def not_wanted?(manufacturer)
    SKIPPED_BRANDS.include?(manufacturer)
  end
end
