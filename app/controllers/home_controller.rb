class HomeController < ApplicationController
  skip_before_action :authenticate_tenant!, :only => [ :index ]

  def index
    if current_user
      if session[:tenant_id]
        Tenant.set_current_tenant session[:tenant_id]
      else
        Tenant.set_current_tenant current_user.tenants.first
      end
      
      @tenant = Tenant.current_tenant
      @projects = Project.by_user_plan_and_tenant(@tenant.id, current_user)
      
      params[:tenant_id] = @tenant.id
    
    else 
      flash[:warning] = "Please signup an account or login"
    end
    
    
  end
end
