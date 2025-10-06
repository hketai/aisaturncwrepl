class SaturnAgentProfilePolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    true
  end
  
  def update?
    true
  end
  
  def destroy?
    true
  end
  
  def chat?
    true
  end
end
