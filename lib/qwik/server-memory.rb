$LOAD_PATH << '..' unless $LOAD_PATH.include? '..'
#require 'qwik/farm'	# Do not add farm here.

module Qwik
  class ServerMemory
    def initialize(config)
      @config = config
      @cache = {}
    end

    def [](k)
      @cache[k]
    end

    def []=(k, v)
      @cache[k] = v
    end

    # farm
    def farm
      @farm = Farm.new(@config, self) unless defined? @farm
      @farm
    end

    # template
    def template
      @template = TemplateFactory.new(@config) unless defined? @template
      @template
    end

    # catalog
    def catalog
      unless defined? @catalog
	@catalog = CatalogFactory.new
	@catalog.load_all_here('catalog-??.rb')
      end
      @catalog
    end

    # act-qrcode
    def qrcode
      @qrcode = QRCodeMemory.new(@config, self) unless defined? @qrcode
      @qrcode
    end

    # act-theme
    def theme
      @theme = ThemeFactory.new(@config) unless defined? @theme
      @theme
    end

    # common-session
    def sessiondb
      @sessiondb = SessionDB.new(@config) unless defined? @sessiondb
      @sessiondb
    end
  end
end
