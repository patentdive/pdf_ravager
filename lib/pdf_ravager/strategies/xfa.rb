module PDFRavager
  module Strategies
    class XFA
      attr_accessor :doc, :xfa

      def initialize(stamper)
        @xfa = stamper.getAcroFields.getXfa
        @doc = to_nokogiri_xml
      end

      def set_field_values(template)
        template.xfa_fields.each do |f|
          get_matches(f).each{|node| f.set_xfa_value(node) }
        end
        xfa.setDomDocument(doc.to_java)
        xfa.setChanged(true)
      end

      def set_read_only
        doc.xpath("//*[local-name()='field']").each do |node|
          node["access"] = "readOnly"
        end
        xfa.setDomDocument(doc.to_java)
        xfa.setChanged(true)
      end

      private

      def to_nokogiri_xml
        # the double-load is to work around a Nokogiri bug I found:
        # https://github.com/sparklemotion/nokogiri/issues/781
        Nokogiri::XML(Nokogiri::XML::Document.wrap(xfa.getDomDocument).to_xml)
      end

      def get_matches(f)
        matches = strict_matches(f)
        if matches.empty?
          matches = loose_matches(f)
        end
        matches
      end

      def strict_matches(f)
        doc.xpath(f.xfa_name)
      rescue Nokogiri::XML::XPath::SyntaxError
        []
      end

      def loose_matches(f)
        doc.xpath("//*[local-name()='field'][@name='#{f.xfa_name}']")
      end

    end
  end
end
