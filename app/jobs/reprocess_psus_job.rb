class ReprocessPsusJob < ApplicationJob
  queue_as :default

  CYBENETICS_PSU_URL = "https://www.cybenetics.com/index.php?option=power-supplies"

  PSU     = Struct.new(
    *PowerSupply.column_names.map(&:to_sym) - [:id, :created_at, :updated_at]
  )
  PSUS    = {}
  ATX_MAP = {
    'ETA & LAMBDA 230V' => 'ATX',
    'ATX V3.0 230V'     => 'ATX 3.0',
    'ATX V3.1 230V'     => 'ATX 3.1',
  }

  def perform
    PowerSupply.delete_all
    begin
      @options = Selenium::WebDriver::Chrome::Options.new
      @options.add_argument("--headless")
      @driver = Selenium::WebDriver.for :chrome, options: @options

      temp_key = manufacturer_links.keys.first
      add_for_manufaturer(temp_key)

      # manufacturer_links.keys.each do |link|
      #   add_for_manufaturer(link)
      # end

      PSUS.values.each do |data|
        PowerSupply.create(data.to_h)
      end
    ensure
      @driver.quit
    end
  end

  private

  def manufacturer_links
    @manufacturer_links = {}
    @driver.navigate.to CYBENETICS_PSU_URL
    elements = @driver.find_elements(:css, '#myTable th a')
    elements.each { |e| @manufacturer_links[e.attribute(:href)] = e.text }
    @manufacturer_links.except!(@manufacturer_links.keys.last)
  end

  def add_for_manufaturer(link)
    @driver.navigate.to link

    ATX_MAP.each do |k, v|
      add_all_for(link, k, v)
    end
  end

  def add_all_for(link, button_text, atx_version)
    sleep 2
    button = @driver.find_element(link_text: button_text)
    button.click
    sleep 2
    trs = @driver.find_elements(:css, '#myTable tr')[3..-1]
    trs.each do |tr|
      data  = tr.find_elements(:tag_name, "td").map(&:text)[0..-3]
      attrs = data + [@manufacturer_links[link], atx_version]
      PSUS.update(attrs.first=>PSU.new(*attrs))
    end
  end
end
