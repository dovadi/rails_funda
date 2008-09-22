class Streamlined::Column::Addition < Streamlined::Column::Base
  attr_accessor :name, :sort_column

  def initialize(sym, parent_model)
    @name = sym.to_s
    @setter_name = @name + '='
    @human_name = sym.to_s.humanize
    @parent_model = parent_model
    @read_only = !@parent_model.instance_methods.include?(@setter_name)
   end 

  def render_td_edit(view, item)
    result = render_input_field(view, field_type, model_underscore, name, html_options)
    wrap(result)
  end
  alias :render_td_new :render_td_edit
  alias :render_td_list :render_td_show 
  
  def addition?
    true
  end

  # Array#== calls this
  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class === o
    return name.eql?(o.name)
  end
  
  def sort_column
    @sort_column.blank? ? name : @sort_column
  end
  
  def render_td_show(view, item)
    render_content(view, item)
  end
  
  
end
