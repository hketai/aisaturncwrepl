module Saturn
  class ToolBase
    attr_reader :agent_profile, :name, :description, :parameters
    
    def initialize(agent_profile)
      @agent_profile = agent_profile
      configure_tool
    end
    
    def definition
      {
        type: 'function',
        function: {
          name: @name,
          description: @description,
          parameters: @parameters
        }
      }
    end
    
    def execute(arguments)
      raise NotImplementedError, 'Subclass must implement execute method'
    end
    
    private
    
    def configure_tool
      raise NotImplementedError, 'Subclass must implement configure_tool method'
    end
  end
end
