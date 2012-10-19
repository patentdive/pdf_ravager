require 'json'
require 'pdf_ravager/ravager' if RUBY_PLATFORM =~ /java/

module PDFRavager
  class PDF
    attr_reader :name, :fields

    def initialize(name=nil, opts={})
      @name = name if name
      @fields = opts[:fields] || []
    end

    def text(name, value, opts={})
      return if opts.has_key?(:when)   && !opts[:when]
      return if opts.has_key?(:if)     && !opts[:if]
      return if opts.has_key?(:unless) && opts[:unless]
      @fields << {:name => name, :value => value, :type => :text}
    end

    def radio_group(gname, &blk)
      fields = []
      # TODO: replace w/ singleton method?
      PDF.instance_eval do
        send(:define_method, :fill) do |name, opts={}|
          return if opts.has_key?(:when)   && !opts[:when]
          return if opts.has_key?(:if)     && !opts[:if]
          return if opts.has_key?(:unless) && opts[:unless]
          fields << {:name => "#{gname}.#{name}", :value => true, :type => :radio}
        end
        blk.call
        send(:undef_method, :fill)
      end

      @fields += fields
    end

    def checkbox_group(gname, &blk)
      fields = []
      # TODO: replace w/ singleton method?
      PDF.instance_eval do
        send(:define_method, :check) do |name, opts={}|
          return if opts.has_key?(:when)   && !opts[:when]
          return if opts.has_key?(:if)     && !opts[:if]
          return if opts.has_key?(:unless) && opts[:unless]
          fields << {:name => "#{gname}.#{name}", :value => true, :type => :checkbox}
        end
        blk.call
        send(:undef_method, :check)
      end

      @fields += fields
    end

    if RUBY_PLATFORM =~ /java/
      def ravage(file, opts={})
        PDFRavager::Ravager.open(opts.merge(:in_file => file)) do |pdf|
          @fields.each do |f|
            pdf.set_field_value(f[:name], f[:value])
          end
        end
      end
    else
      def ravage(file, opts={})
        raise "You can only ravage .pdfs using JRuby, not #{RUBY_PLATFORM}!"
      end
    end

    def ==(other)
      self.name == other.name && self.fields == other.fields
    end

    def to_json(*args)
      {
        "json_class"   => self.class.name,
        "data"         => {"name" => @name, "fields" => @fields }
      }.to_json(*args)
    end

    def self.json_create(obj)
      fields = obj["data"]["fields"].map do |f|
        # symbolize the keys
        f = f.inject({}){|h,(k,v)| h[k.to_sym] = v; h}
        f[:type] = f[:type].to_sym if f[:type]
        f
      end
      o = new(obj["data"]["name"], :fields => fields)
    end
  end
end

module Kernel
  def pdf(name=nil, opts={}, &blk)
    r = PDFRavager::PDF.new(name, opts)
    r.instance_eval(&blk)
    r
  end
end