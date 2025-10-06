class Api::V1::Accounts::Saturn::AutoRepliesController < Api::V1::Accounts::Saturn::BaseController
  before_action :set_auto_reply, only: [:show, :destroy]
  
  def index
    if params[:agent_id].present?
      @auto_replies = Current.account.saturn_auto_replies
                                     .for_agent(params[:agent_id])
                                     .ordered
                                     .limit(100)
    else
      @auto_replies = Current.account.saturn_auto_replies
                                     .ordered
                                     .limit(100)
    end
  end
  
  def show; end
  
  def destroy
    @auto_reply.destroy!
    head :no_content
  end
  
  private
  
  def set_auto_reply
    @auto_reply = Current.account.saturn_auto_replies.find(params[:id])
  end
end
