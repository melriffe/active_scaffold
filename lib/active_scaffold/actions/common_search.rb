module ActiveScaffold::Actions
  module CommonSearch
    def self.included(base)
      unless base < InstanceMethods
        base.send :include, InstanceMethods
        base.before_filter :search_authorized_filter, :only => :show_search
        base.before_filter :store_search_params_into_session, :only => [:index]
        base.before_filter :do_search, :only => [:index]
        base.helper_method :search_params
      end
    end

    module InstanceMethods
      def show_search
        respond_to_action(search_partial || :search)
      end
      
      protected
      def do_search
      end
      
      def search_partial
        if params[:kind].present? && active_scaffold_config.actions.include?(params[:kind])
          params.delete(:kind)
        end
      end
      
      def store_search_params_into_session
        if active_scaffold_config.store_user_settings
          active_scaffold_session_storage[:search] = params.delete :search if params[:search]
        else
          @search_params = params.delete :search
        end
      end

      def search_params
        @search_params || active_scaffold_session_storage[:search]
      end

      def global_search_ignore?
        active_scaffold_config.list.always_show_search == true
      end
      
      # The default security delegates to ActiveRecordPermissions.
      # You may override the method to customize.
      def search_authorized?
        authorized_for?(:crud_type => :read)
      end
      
      def search_authorized_filter
        action = active_scaffold_config.list.send(search_partial)
        link = action.link || action.class.link
        raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
      end
    end
  end
end
