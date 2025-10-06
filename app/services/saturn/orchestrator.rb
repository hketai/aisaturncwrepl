module Saturn
  class Orchestrator
    attr_reader :agent_profile, :conversation_history, :llm_service
    
    MAX_ITERATIONS = 8
    
    def initialize(agent_profile:, api_key: nil)
      @agent_profile = agent_profile
      @conversation_history = []
      @llm_service = Saturn::LlmService.new(
        api_key: api_key,
        model: agent_profile.model_name || 'gpt-4o-mini',
        temperature: agent_profile.ai_temperature || 0.7
      )
      @available_tools = build_tool_registry
    end
    
    def process(user_input, context: {})
      initialize_conversation(user_input, context)
      
      MAX_ITERATIONS.times do |iteration|
        append_final_instruction if iteration == MAX_ITERATIONS - 1
        
        result = llm_service.generate_completion(
          conversation_history,
          tools: tool_definitions
        )
        
        return handle_error(result) unless result[:success]
        
        if result[:tool_call]
          tool_call_data = result[:tool_call]
          append_tool_call_message(tool_call_data)
          
          tool_result = execute_tool(tool_call_data)
          append_tool_result_message(tool_call_data['id'], tool_result)
        else
          return format_final_response(result[:content])
        end
      end
      
      format_final_response(conversation_history.last[:content])
    end
    
    private
    
    def initialize_conversation(user_input, context)
      system_prompt = build_system_prompt(context)
      @conversation_history = [
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_input }
      ]
    end
    
    def build_system_prompt(context)
      <<~PROMPT
        You are #{agent_profile.name}, an AI assistant for #{agent_profile.product_context || 'customer support'}.
        
        #{agent_profile.description}
        
        Behavior Rules:
        #{format_rules(agent_profile.behavior_rules)}
        
        Safety Guidelines:
        #{format_rules(agent_profile.safety_guidelines)}
        
        Context: #{context.to_json}
        
        Instructions:
        - Provide helpful, accurate responses
        - Use available tools when needed
        - Be concise and professional
        - If you cannot help, explain why clearly
      PROMPT
    end
    
    def format_rules(rules)
      return 'None specified' if rules.blank?
      
      rules.map.with_index { |rule, i| "#{i + 1}. #{rule}" }.join("\n")
    end
    
    def build_tool_registry
      [
        Saturn::Tools::KnowledgeSearch.new(agent_profile),
        Saturn::Tools::HandoffAgent.new(agent_profile)
      ]
    end
    
    def tool_definitions
      @available_tools.map(&:definition)
    end
    
    def execute_tool(tool_call)
      function_name = tool_call.dig('function', 'name')
      arguments = JSON.parse(tool_call.dig('function', 'arguments') || '{}')
      
      tool = @available_tools.find { |t| t.name == function_name }
      return "Tool not found: #{function_name}" unless tool
      
      tool.execute(arguments)
    rescue StandardError => e
      "Tool execution failed: #{e.message}"
    end
    
    def append_message(role, content)
      @conversation_history << { role: role, content: content }
    end
    
    def append_tool_call_message(tool_call)
      @conversation_history << {
        role: 'assistant',
        content: nil,
        tool_calls: [tool_call]
      }
    end
    
    def append_tool_result_message(tool_call_id, result)
      @conversation_history << {
        role: 'tool',
        tool_call_id: tool_call_id,
        content: result.is_a?(Hash) ? result.to_json : result.to_s
      }
    end
    
    def append_final_instruction
      append_message('system', 'Provide your final answer now.')
    end
    
    def format_final_response(content)
      {
        success: true,
        response: content,
        agent_name: agent_profile.name,
        timestamp: Time.current
      }
    end
    
    def handle_error(result)
      {
        success: false,
        error: result[:error],
        agent_name: agent_profile.name
      }
    end
  end
end
