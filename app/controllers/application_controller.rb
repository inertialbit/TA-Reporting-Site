class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :logged_in?, :is_admin?

  after_filter :store_location
  
  prepend_before_filter :log_params

  private
    def log_params
      logger.debug("PARAMS: #{params.inspect}")
    end
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def logged_in?
      !!current_user
    end

    def is_admin?
      logged_in? and current_user.is_admin?
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page."
        redirect_to new_user_session_path
        return false
      end
    end

    def require_admin_user
      unless is_admin?
        store_location
        flash[:notice] = "You must be an admin to access this page."
        redirect_to new_user_session_path
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page."
        redirect_to '/'
        return false
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default)
      unless session[:return_to] && session[:return_to] == new_user_session_path
        redirect_to(session[:return_to] || default)
      else
        redirect_to(default)
      end
      session[:return_to] = nil
    end
end
