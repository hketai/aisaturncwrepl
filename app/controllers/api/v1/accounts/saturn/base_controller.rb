class Api::V1::Accounts::Saturn::BaseController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  
  private
  
  def check_authorization
    authorize(:saturn_agent_profile)
  end
end
