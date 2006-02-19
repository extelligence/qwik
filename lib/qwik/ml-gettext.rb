#
# Copyright (C) 2002-2004 Satoru Takabayashi <satoru@namazu.org> 
# Copyright (C) 2003-2006 Kouichirou Eto
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms of 
# the GNU General Public License version 2.
#

$LOAD_PATH << '..' unless $LOAD_PATH.include? '..'

module QuickML
  module GetText
    def set_catalog (catalog)
      @catalog = nil
      @gettext_catalog = catalog
    end

    def set_charset(charset)
      @message_charset = nil
      @gettext_charset = charset
    end

    # used in ml-processor.rb, ml-quickml.rb, m-session.rb
    def codeconv (text)
      return text if @gettext_catalog.nil?
      method = @gettext_catalog[:codeconv_method]
      return text if method.nil?
      return text.send(method)
    end

    def gettext (text, *args)
      @gettext_catalog	= nil if ! defined?(@gettext_catalog)
      @catalog		= nil if ! defined?(@catalog)
      @message_charset	= nil if ! defined?(@message_charset)
      @gettext_charset	= nil if ! defined?(@gettext_charset)
      @gettext_catalog = @catalog if @catalog && @gettext_catalog.nil?
      if @message_charset && @gettext_charset.nil?
	@gettext_charset = @message_charset
      end
      unless @gettext_catalog && @gettext_catalog[:charset] == @gettext_charset
	return sprintf(text, *args)
      end
      translated_message = @gettext_catalog[text]
      if translated_message
	text = sprintf(translated_message, *args)
	method = @gettext_catalog[:codeconv_method]
	return text.send(method) if method
	return text
      end
      return sprintf(text, *args)
    end
    alias :_ :gettext

    def gettext2 (text)
      @gettext_catalog	= nil if ! defined?(@gettext_catalog)
      @catalog		= nil if ! defined?(@catalog)
      @message_charset	= nil if ! defined?(@message_charset)
      @gettext_charset	= nil if ! defined?(@gettext_charset)
      @gettext_catalog = @catalog if @catalog && @gettext_catalog.nil?
      if @message_charset && @gettext_charset.nil?
	@gettext_charset = @message_charset
      end
      unless @gettext_catalog && @gettext_catalog[:charset] == @gettext_charset
	return text
      end
      translated_message = @gettext_catalog[text]
      if translated_message
	text = translated_message
	method = @gettext_catalog[:codeconv_method]
	return text.send(method) if method
	return text
      end
      return text
    end
    alias :__ :gettext2
  end
end

if $0 == __FILE__
  require 'qwik/testunit'
  require 'qwik/ml-catalog-factory'
  require 'qwik/util-kconv'
  $test = true
end

if defined?($test) && $test
  class MockMLGetText
    include QuickML::GetText

    def test_all(t)
      # $KCODE = 's'

      # test_set_catalog
      cf = QuickML::CatalogFactory.new
      cf.load_all_here('catalog-ml-??.rb')
      catalog_ja = cf.get_catalog('ja')
      set_catalog(catalog_ja)

      # test before set catalog
      @catalog		= nil
      @message_charset	= nil
      set_catalog(nil)
      set_charset(nil)
      t.ok_eq('hello', gettext('hello'))
      t.ok_eq("Info: a\n", gettext("Info: %s\n", 'a'))
      t.ok_eq("If you agree, then,\n", gettext("If you agree, then,\n"))

      # test_codeconv
      t.ok_eq('あ', codeconv('あ'))

      # test after set catalog
      @catalog		= catalog_ja
      @message_charset	= 'iso-2022-jp'
      set_catalog(catalog_ja)
      set_charset('iso-2022-jp')
      t.ok_eq('こんにちは'.set_sourcecode_charset.to_mail_charset, gettext('hello'))
      t.ok_eq('こんにちは'.set_sourcecode_charset.to_mail_charset, _('hello'))
      t.ok_eq('こんにちは'.set_sourcecode_charset.to_mail_charset, gettext2('hello'))
      t.ok_eq('こんにちは'.set_sourcecode_charset.to_mail_charset, gettext('hello'))
      t.ok_eq("使い方: a\n".set_sourcecode_charset.to_mail_charset, gettext("Info: %s\n", 'a'))
      t.ok_eq("もし承認する場合、\n".set_sourcecode_charset.to_mail_charset,
	      gettext("If you agree, then,\n"))

      # test_codeconv_ja
      t.ok_eq("\e$B$\"\e(B", codeconv('あ'))
    end
  end

  class TestMockMLGetText < Test::Unit::TestCase
    def test_all
      mock = MockMLGetText.new
      mock.test_all(self)
    end
  end
end
