module TableCloth
  class Presenter
    attr_reader :view_context, :table_definition, :objects,
      :columns

    def initialize(objects, table, view)
      @view_context     = view
      @table_definition = table
      @objects          = objects

      @columns = table_definition.columns

      if actions?
        action_options = table_definition.actions.inject({}) do |a, action|
          a[action.action] = action.options; a
        end

        columns[:actions] = Columns::Action.new(:actions, actions: action_options)
      end
    end

    # Short hand so your fingers don't hurt
    def v
      view_context
    end

    def render_table
      raise NoMethodError, "You must override the .render method"
    end

    def render_header
      raise NoMethodError, "You must override the .header method"
    end

    def render_rows
      raise NoMethodError, "You must override the .rows method"
    end

    def column_names
      names = columns.inject([]) do |c, (key,column)|
        c << (column.options[:name] || key.to_s.humanize); c
      end

      names << 'Actions' if actions?
      names
    end

    def row_values(object)
      column_values = columns.inject([]) do |values, (key, column)|
        values << column.value(object, view_context); values
      end
    end

    def rows
      objects.inject([]) do |row, object|
        row << row_values(object); row
      end
    end

    def actions?
      table_definition.actions.any?
    end

    def wrapper_tag(type, value=nil, &block)
      content = if block_given?
        v.content_tag(type, TableCloth.config_for(type), &block)
      else
        v.content_tag(type, value, TableCloth.config_for(type))
      end
    end
  end
end