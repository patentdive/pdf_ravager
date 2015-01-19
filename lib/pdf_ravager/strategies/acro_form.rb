module PDFRavager
  module Strategies
    class AcroForm
      attr_accessor :stamper, :afields

      def initialize(stamper)
        @stamper = stamper
        @afields = stamper.getAcroFields
      end

      def set_field_values(template,opts)
        template.acro_fields.select do |f|
          assign_field(f.acro_form_name, f.acro_form_value)
        end
      end

      def set_read_only
        @stamper.setFormFlattening(true)
      end

      private

      def assign_field(name,value)
        # first assume the user has provided the full/raw SOM path
        unless @afields.setField(name,value)
          # if that fails, try setting the shorthand version of the path
          @afields.setField(FieldTypes::AcroForm::SOM.short_name(name), value)
        end
      rescue java.lang.NullPointerException
        false
      end

    end
  end
end
