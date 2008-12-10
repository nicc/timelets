# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def page_title
    title = "Timelets"
    title << ' - ' + @page_title unless @page_title.nil?
    title
  end
  
  def full_time(object_name, method, options = {})
    render :partial => 'shared/full_time_control',
           :locals => {
             :object_name => object_name, 
             :method => method,
             :options => options
           }
  end
  
  def replace_list(page, partial, opts={})
    page.replace_html('list-content', {:partial => partial.to_s}.merge(opts))
  end
  
  def replace_admin_ops(page, partial, opts={})
    page.replace_html('admin_operations', {:partial => partial.to_s}.merge(opts))
  end

end
