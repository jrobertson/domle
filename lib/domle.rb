#!/usr/bin/env ruby

# file: domle.rb

require 'rexle'
require 'rxfhelper'


class Style < Hash

  def initialize(parent, h)
    @parent = parent

    super().merge! h

  end
  
  def []=(k,v)

    super(k,v)
    @parent[:style] = self.map{|x| x.join(':') }.join(';')
    @parent.callback.refresh
    
  end
end

class Attributes
  
  attr_reader :callback
  
  def initialize(parent: nil)
    @callback = parent
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
  
  class Element < Rexle::Element

    def initialize(name=nil, value: nil, \
                          attributes: Attributes.new(parent: self), rexle: nil)
      
      attributes.merge!(style: '') unless attributes.has_key? :style
      super(name, value: value, attributes: attributes, rexle: rexle)
      
    end
    
    def self.attr2_accessor(*a)

      a.concat %i(id transform)
      a.concat %i(onmousemove onmousedown) # DOM events      
      
      a.each do |attribute|

        class_eval do

          define_method attribute.to_s.gsub('-','_').to_sym do 
            attributes[attribute]
          end

          define_method (attribute.to_s + '=').to_sym do |val|
            attributes[attribute] = val
            @rexle.refresh
            val
          end

        end
      end
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
  end
  
  class Script < Element

  end  
  
  class Style < Element
    

  end

  def initialize(x=nil, callback: nil)

    super x    
    find_add_css()
    @callback = callback
  end  
  
  def refresh()
    @callback.refresh if @callback
  end
  
  private
  
  def add_css(s, override: true)

    # parse the CSS
    
    a = s.split(/}/)[0..-2].map do |entry|

      raw_selector,raw_styles = entry.split(/{/,2)

      h = raw_styles.strip.split(/;/).inject({}) do |r, x| 
        k, v = x.split(/:/,2).map(&:strip)
        r.merge(k.to_sym => v)
      end

      [raw_selector.split(/,\s*/).map(&:strip), h]
    end      
    
    # add each CSS style attribute to the element
    # e.g. a = [[['line'],{stroke: 'green'}]]

    a.each do |x|

      selectors, style = x

      selectors.each do |selector|

        style.each do |k,v|

          self.root.css(selector).each do |element|

            element.style[k] = v unless override == false and element.style.has_key? k
          end
        end

      end
    end
    
  end

  def defined_elements()  
    
    # override this method in your own class
    
  end

  def scan_element(name, attributes=nil, *children)

    return Rexle::CData.new(children.first) if name == '!['
    return Rexle::Comment.new(children.first) if name == '!-'

    type = defined_elements()

    element = type[name.to_sym].new(name, attributes: attributes, rexle: self)  

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