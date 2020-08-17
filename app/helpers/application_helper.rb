module ApplicationHelper

  def action_link(url, icon, style, **params)
    params[:method] ||= :get
    content_tag :a, class: "ui compact icon button #{style} mb-1",
                role: 'button',
                href: url,
                'data-remote': params[:remote] || false,
                'data-method': params[:method] do
      content_tag :i, '', class: "icon #{icon}", style: 'margin: 0px;'
    end
  end


  def setup_search_form(builder)
    fields = builder.grouping_fields builder.object.new_grouping, object_name: 'new_object_name', child_index: 'new_grouping' do |f|
      render('grouping_fields', f: f)
    end
    content_for :document_ready, %Q{
      <script type="text/javascript">
        $(function() {
          console.log('Hello');
          var search = new Search({grouping: "#{escape_javascript(fields)}"});
          $(document).on("click", "button.add_fields", function() {
            search.add_fields(this, $(this).data('fieldType'), $(this).data('content'));
            return false;
          });
          $(document).on("click", "button.remove_fields", function() {
            search.remove_fields(this);
            return false;
          });
          $(document).on("click", "button.nest_fields", function() {
            search.nest_fields(this, $(this).data('fieldType'));
            return false;
          });
        });
      </script>
    }.html_safe
  end

  def condition_fields
    %w(fields condition).freeze
  end

  def value_fields
    %w(fields value).freeze
  end

  def button_to_remove_fields
    tag.button 'Remove', class: 'ui compact button remove_fields'
  end

  def button_to_add_fields(f, type)
    new_object, name = f.object.send("build_#{type}"), "#{type}_fields"
    fields = f.send(name, new_object, child_index: "new_#{type}") do |builder|
      render(name, f: builder)
    end

    tag.button button_label[type], class: 'ui compact button add_fields btn', 'data-field-type': type, 'data-content': "#{fields}"
  end

  def button_to_nest_fields(type)
    tag.button button_label[type], class: 'ui compact button nest_fields btn', 'data-field-type': type
  end

  def button_label
    { value:     'Add Value',
      condition: 'Add Condition',
      sort:      'Add Sort',
      grouping:  'Add Condition Group' }.freeze
  end
end
