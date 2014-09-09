module EasyFilter
  # Load ModuleAdditions and views into Rails env
  class Railtie < Rails::Railtie
    initializer 'easy_filter.model_additions' do
      ActiveSupport.on_load :active_record do
        extend ModelAdditions
      end
    end

    initializer 'easy_filter.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
