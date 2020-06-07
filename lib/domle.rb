#!/usr/bin/env ruby

# file: domle.rb

require 'rexle'
require 'csslite'
require 'rxfhelper'


class Style < Hash

  def initialize(parent, h)
    @parent = parent

    super().merge! h

  end
  
  def []=(k,v)

    super(k,v)
    @parent[:style] = self.map{|x| x.join(':') }.join(';')
    @parent.callback.refresh if @parent.callback
    
  end
end

class VisualAttributes < Attributes
  
  attr_reader :callback
  
  def initialize(x, parent: nil)
    @callback = parent
    self.merge! x if x
  end  
  
  def style(parent=nil)
    
    @callback ||= parent
    
    if @style.nil? then

      h = self[:style].split(';').inject({}) do |r, x|
        k, v = x.split(':',2).map(&:strip)
        r.merge(k.to_sym => v)
      end

      @style = Style.new(self, h)

    end
    @style
  end
  
end

class Domle < Rexle
  using ColouredText
  
  class Element < Rexle::Element
    

    class ClassList
      
      def initialize(a, rexle, node)
        @a, @rexle, @node = a, rexle, node
      end
      
      def toggle(name)
        @a.include?(name) ? @a.delete(name) : @a << name
        puts '@rexle?: ' + @rexle.inspect if @debug
        @rexle.refresh_css(@node) if @rexle
      end        
    end    

    @default = {}
    @attr_map = {}
    attr_reader :attr_map
    
    def initialize(name=self.class.to_s.downcase[/\w+$/], value: nil, \
                          attributes: {}, rexle: nil)
      
      attributes.merge!(style: '') unless attributes.has_key? :style
      super(name, value: value, attributes: VisualAttributes.new(attributes), rexle: rexle)
      
    end
    
    def self.attr2_accessor(*a)

      a.concat %i(id transform)
      # DOM events      
      a.concat %i(onload onmousemove onmousedown onmouseenter 
      onmouseleave onclick onscroll onkeydown onkeyup) 
      
      a.each do |attribute|

        class_eval do

          define_method attribute.to_s.gsub('-','_').to_sym do 
            attributes[attribute]
          end

          define_method (attribute.to_s + '=').to_sym do |val|
            attributes[attribute] = val
            rexle().refresh if rexle?
            attr_update(attribute, val)
            val
          end

        end
      end
      
      def rexle?()
        not @rexle.nil?
      end
      
      def rexle()
        @rexle
      end
            
    end
    
    def self.attr_mapper(h)
      @attr_map = h
    end
    
    def active?()
      @active
    end
    
    def active=(v)
      @active = v
    end    
    
    def classlist()
      
      a = attributes[:class]
      cl = ClassList.new(a, @rexle, self)
      

      
      
      return cl
    end
    
    def style()
      attributes.style(@rexle)
    end
    
    
    def hotspot?(x,y)

      (boundary.first.is_a?(Array) ? boundary : [boundary]).all? do |box|
        x1, y1, x2, y2 = box
        (x1..x2).include? x and (y1..y2).include? y
      end
    end    
    
    def obj=(v)
      @obj = v
    end

    def obj()
      @obj
    end
    
    
    private
    
    def attr_update(name, val)
      return unless @attr_map
      puts 'inside attr_update, @attr_map: ' + @attr_map.inspect if @debug
      name = (@attr_map[name].to_s + '=').to_sym      
      @obj.method(name).call(val) if @obj.respond_to? name
    end
  end
  
  class Script < Element

  end  
  
  class Style < Element
    

  end
  
  attr_reader :event

  def initialize(src='<svg/>', callback: nil, rexle: nil, debug: false)

    @callback, @debug, @rexle = callback, debug, rexle
    puts 'inside Domle initialize'.info if @debug
    puts 'src:' + src.inspect if @debug
    
    super(RXFHelper.read(src).first, rexle: self)
    @debug = debug
    
    puts 'before find add_css' if @debug
    find_add_css() if src

    
    @event = {
      keydown: [],
      keyup: [],
      mousemove: [],
      mousedown: [],
      mouseenter: [],
      mouseleave: [],
      scroll: []
    }
    
  end  
  
  def addevent_listener(event, method_name)
        
    @event[event.to_sym] << method_name
    
  end
    
  
  def element_by_id(id)
    @doc.root.element("//*[@id='#{id}']")
  end
  
  def elements_by_name(name)
    @doc.root.xpath("//*[@name='#{name}']")
  end  
    
  def elements_by_tagname(name)
    @doc.root.xpath("//#{name}")
  end    
   
  def refresh()
    @callback.refresh if @callback
  end
  
  def refresh_css(node)
    find_add_css(node.parent)
  end
  
  protected
  
  def add_default_css()
  end
  
  def add_external_css(node=nil)
    
    # check for an external CSS file
    if @instructions and @instructions.any? then

      hrefs = @instructions.inject([]) do |r,x| 

        if x[0] =~ /xml-stylesheet/i and x[1] =~ /text\/css/i then

          r << x[1][/href\s*=\s*["']([^'"]+)/,1]
        else
          r
        end
      end
      
      add_css hrefs.map{|x| RXFHelper.read(x).first}.join, node
      
    end
    
  end
  
  def add_inline_css(node=nil)
    puts 'inside add_inline_css' if @debug
    @doc.root.xpath('//style').each {|e|  add_css e.text.to_s, node } 
  end
  
  def find_add_css(node=nil)
    
    puts 'inside find_add_css' if @debug
    add_default_css() unless node
    add_inline_css(node)
    add_external_css(node)
  end    
  
  private
  
  def add_css(s, node=@doc, override: true)

    puts 'add_css s: ' + s.inspect if @debug
    css = CSSLite.new s, debug: @debug
    node ||= @doc
    puts 'before propagate node: ' + node.inspect if @debug
    css.propagate node
    puts node.xml if @debug
  end

  # override this method in your own class
  #
  def defined_elements()
    {
      doc: Rexle::Element      
    }
  end  

  def scan_element(name, attributes=nil, *children)

    return Rexle::CData.new(children.first) if name == '!['
    return Rexle::Comment.new(children.first) if name == '!-'

    type = defined_elements()

    klass_element = type[name.to_sym] || Element
    element = klass_element.new(name, attributes: attributes, rexle: @rexle)

    if children then

      children.each do |x|
        
        if x.is_a? Array then

          element.add_element scan_element(*x)        
          
        elsif x.is_a? String then

          if x.is_a? String  then

            element.add_element(x) if x.strip.length > 0
            
          elsif x.name == '![' then

            e = Rexle::CData.new(x)
            element.add_element e
            
          elsif x.name == '!-' then

            e = Rexle::Comment.new(x)
            element.add_element e
            
          end
          
        end
      end
    end
    
    return element
  end
  
    
end
