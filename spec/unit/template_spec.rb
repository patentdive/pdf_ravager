require File.dirname(__FILE__) + '/unit_helper'
require 'pdf_ravager/template'

class TestPDF < MiniTest::Unit::TestCase

  def setup
    @template = PDFRavager::Template.new do |t|
      t.text      'text',        'foo'
      t.rich_text 'rich_text',   '<b>foo</b>'
      t.check     'checkbox1'
      t.uncheck   'checkbox2'
      t.fill      'radio_group', 'button'
    end
  end

  def test_that_text_is_set
    assert_includes @template.fields, PDFRavager::Fields::Text.new('text', 'foo')
  end

  def test_that_rich_text_is_set
    assert_includes @template.fields, PDFRavager::Fields::RichText.new('rich_text', '<b>foo</b>')
  end

  def test_that_checkbox_is_set
    assert_includes @template.fields, PDFRavager::Fields::Checkbox.new('checkbox1', true)
  end

  def test_that_checkbox_is_unset
    assert_includes @template.fields, PDFRavager::Fields::Checkbox.new('checkbox2', false)
  end

  def test_that_radio_button_is_filled
    assert_includes @template.fields, PDFRavager::Fields::Radio.new('radio_group', 'button')
  end

end