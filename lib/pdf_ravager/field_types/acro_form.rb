require 'java'
require File.dirname(__FILE__)  + '/../../../vendor/iText-4.2.0'

module PDFRavager
  module FieldTypes
    module AcroForm

      module SOM
        def self.short_name(str)
          com.lowagie.text.pdf.XfaForm::Xml2Som.getShortName(self.escape(str))
        end

        def self.escape(str)
          com.lowagie.text.pdf.XfaForm::Xml2Som.escapeSom(str) # just does: str.gsub(/\./) { '\\.' }
        end
      end

      def set_acro_form_value(acro_fields)
        begin
          acro_fields.setField(SOM.short_name(@name), @value)
          true
        rescue java.lang.NullPointerException
          false
        end
      end

    end
  end
end
