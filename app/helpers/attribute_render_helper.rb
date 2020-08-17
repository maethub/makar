module AttributeRenderHelper

  def render_attribute(record, attribute)
    # Check multiple
    if record.schema.multiple?(attribute)
      capture do
        concat '<ul>'.html_safe
        record.send(attribute).each do |v|
          concat '<li>'.html_safe
          concat self.send("render_#{record.schema.attribute_type(attribute)}_attribute", v)
          concat '</li>'.html_safe
        end
        concat '</ul>'.html_safe
      end
    else
      self.send("render_#{record.schema.attribute_type(attribute)}_attribute", record.send(attribute))
    end
  end



  def render_string_attribute(value)
    capture do
      concat value
    end
  end

  def render_html_attribute(value)
    capture do
      concat value&.html_safe
    end
  end

  def render_int_attribute(value)
    capture do
      concat value
    end
  end

  def render_bool_attribute(value)
    capture do
      concat (value ? 'true' : 'false')&.html_safe
    end
  end

  def render_date_attribute(value)
    capture do
      concat Date.parse(value).strftime('%d.%m.%Y')
    end
  end

  def render_code_attribute(value)
    capture do
        concat '<code><pre>'.html_safe
        concat "#{value}"
        concat '</pre></code>'.html_safe
        concat '<hr />'.html_safe
        concat '<br />'.html_safe
    end
  end
end