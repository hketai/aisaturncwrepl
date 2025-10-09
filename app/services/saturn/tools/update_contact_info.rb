module Saturn
  module Tools
    class UpdateContactInfo < Saturn::ToolBase
      private
      
      def configure_tool
        @name = 'update_contact_info'
        @description = 'Müşterinin email veya telefon bilgisini kaydetmek için kullanılır. Müşteri konuşma sırasında email veya telefon bilgisi verdiğinde bu bilgileri contact kaydına ekler. Sadece müşteri açıkça bu bilgileri paylaştığında kullan.'
        @parameters = {
          type: 'object',
          properties: {
            email: {
              type: 'string',
              description: 'Müşterinin email adresi (opsiyonel)'
            },
            phone_number: {
              type: 'string',
              description: 'Müşterinin telefon numarası (opsiyonel, uluslararası formatta: +90XXXXXXXXXX)'
            }
          },
          required: []
        }
      end
      
      public
      
      def execute(arguments)
        email = arguments['email']
        phone_number = arguments['phone_number']
        
        # Return action for AutoRespondJob to handle
        {
          success: true,
          action: 'update_contact_info_requested',
          email: email,
          phone_number: phone_number,
          message: 'İletişim bilgilerinizi aldım, teşekkür ederim!',
          timestamp: Time.current.iso8601
        }.to_json
      end
    end
  end
end
