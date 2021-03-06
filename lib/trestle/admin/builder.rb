module Trestle
  class Admin
    class Builder < Trestle::Builder
      target :admin

      class_attribute :admin_class
      self.admin_class = Admin

      class_attribute :controller
      self.controller = Controller

      def initialize(name, options={})
        # Create admin subclass
        @admin = Class.new(admin_class)
        @admin.options = options

        # Define a constant based on the admin name
        scope = options[:scope] || Object
        scope.const_set("#{name.to_s.camelize}Admin", @admin)

        # Define admin controller class
        # This is done using class_eval rather than Class.new so that the full
        # class name and parent chain is set when Rails' inherited hooks are called.
        @admin.class_eval("class AdminController < #{self.class.controller.name}; end")

        # Set a reference on the controller class to the admin class
        @controller = @admin.const_get("AdminController")
        @controller.instance_variable_set("@admin", @admin)
      end

      def menu(*args, &block)
        if block_given?
          admin.menu = Navigation::Block.new(admin, &block)
        else
          menu { item(*args) }
        end
      end

      def table(options={}, &block)
        admin.table = Table::Builder.build(options.reverse_merge(sortable: true, admin: admin), &block)
      end

      def form(&block)
        admin.form = Form.new(&block)
      end

      def admin(&block)
        @admin.singleton_class.class_eval(&block) if block_given?
        @admin
      end

      def controller(&block)
        @controller.class_eval(&block)
      end

      def routes(&block)
        @admin.additional_routes = block
      end

      def helper(*helpers)
        controller do
          helper *helpers
        end
      end
    end
  end
end
