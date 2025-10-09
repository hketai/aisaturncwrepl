require 'nokogiri'
require 'net/http'
require 'resolv'
require 'ipaddr'

module Saturn
  class UrlScraperService
    attr_reader :url
    
    def initialize(url)
      @url = url
    end
    
    def scrape
      # Validate URL for security and get safe IP
      validation = validate_url(url)
      return validation unless validation[:success]
      
      begin
        uri = URI.parse(url)
        validated_ip = validation[:ip]
        
        # Use Net::HTTP with the validated IP to prevent DNS rebinding
        http = Net::HTTP.new(validated_ip, uri.port)
        http.open_timeout = 10
        http.read_timeout = 10
        
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ssl_version = :TLSv1_2
          
          # Set SNI hostname for proper certificate presentation (Ruby 3.0+)
          original_host = uri.host
          http.hostname = original_host if http.respond_to?(:hostname=)
          
          # Configure SSL context for hostname verification
          http.instance_variable_set(:@ssl_context, OpenSSL::SSL::SSLContext.new)
          http.ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ssl_context.verify_hostname = true
          
          # Custom verification callback - verify both chain and hostname
          http.ssl_context.verify_callback = proc do |preverify_ok, store_context|
            # Only verify hostname on the leaf certificate (depth 0)
            if store_context.error_depth.zero?
              cert = store_context.current_cert
              # Must pass both CA chain verification AND hostname verification
              preverify_ok && OpenSSL::SSL.verify_certificate_identity(cert, original_host)
            else
              # For intermediate/root certs, use standard CA chain verification
              preverify_ok
            end
          end
        end
        
        request = Net::HTTP::Get.new(uri.request_uri)
        request['User-Agent'] = 'Mozilla/5.0 (compatible; AISaturn/1.0)'
        request['Host'] = uri.host  # Set original hostname for Host header
        
        response = http.request(request)
        
        unless response.is_a?(Net::HTTPSuccess)
          return {
            success: false,
            error: "HTTP Error: #{response.code} #{response.message}",
            url: url
          }
        end
        
        html = response.body
        doc = Nokogiri::HTML(html)
        
        # Remove script and style tags
        doc.css('script, style, nav, header, footer').remove
        
        # Extract title
        title = doc.css('title').text.strip
        title = doc.css('h1').first&.text&.strip if title.blank?
        title = extract_domain_name if title.blank?
        
        # Extract main content
        content = extract_content(doc)
        
        {
          success: true,
          title: title,
          content: content,
          url: url
        }
      rescue Timeout::Error => e
        {
          success: false,
          error: "Zaman aşımı: Site yanıt vermiyor",
          url: url
        }
      rescue StandardError => e
        {
          success: false,
          error: "Scraping hatası: #{e.message}",
          url: url
        }
      end
    end
    
    private
    
    def validate_url(url)
      uri = URI.parse(url)
      
      # Only allow HTTP and HTTPS schemes
      unless %w[http https].include?(uri.scheme&.downcase)
        return { success: false, error: 'Only HTTP and HTTPS URLs are allowed' }
      end
      
      host = uri.host
      if host.nil? || host.empty?
        return { success: false, error: 'Invalid URL host' }
      end
      
      # Resolve host to IP address(es) and check each one
      begin
        # Use Resolv to get all IP addresses for the host
        addresses = Resolv.getaddresses(host)
        
        # If no addresses found, try as IP directly
        if addresses.empty?
          addresses = [host]
        end
        
        # Check each resolved IP address and use the first valid one
        validated_ip = nil
        addresses.each do |addr|
          ip = IPAddr.new(addr)
          
          # Block loopback addresses (127.0.0.0/8, ::1)
          if ip.loopback?
            return { success: false, error: 'Loopback addresses are not allowed' }
          end
          
          # Block private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, fc00::/7)
          if ip.private?
            return { success: false, error: 'Private IP addresses are not allowed' }
          end
          
          # Block link-local addresses (169.254.0.0/16, fe80::/10)
          if ip.link_local?
            return { success: false, error: 'Link-local addresses are not allowed' }
          end
          
          # Store the first valid IP
          validated_ip ||= addr
        end
        
        # Ensure we have a valid IP after filtering
        if validated_ip.nil?
          return { success: false, error: 'No valid IP address found after security filtering' }
        end
      rescue IPAddr::InvalidAddressError
        return { success: false, error: 'Invalid IP address format' }
      rescue Resolv::ResolvError
        return { success: false, error: 'Unable to resolve hostname' }
      end
      
      { success: true, ip: validated_ip }
    rescue URI::InvalidURIError => e
      { success: false, error: "Invalid URL format: #{e.message}" }
    end
    
    def extract_content(doc)
      # Try to find main content area
      main_content = doc.css('main, article, .content, .main-content, #content, #main').first
      
      if main_content
        extract_text_from_element(main_content)
      else
        # Fallback to body
        extract_text_from_element(doc.css('body').first)
      end
    end
    
    def extract_text_from_element(element)
      return '' unless element
      
      # Get all paragraph and heading texts
      texts = []
      
      element.css('h1, h2, h3, h4, h5, h6, p, li').each do |node|
        text = node.text.strip
        texts << text if text.present? && text.length > 10
      end
      
      # Join and clean up
      content = texts.join("\n\n")
      content.gsub(/\n{3,}/, "\n\n") # Remove excessive newlines
             .gsub(/[[:space:]]+/, ' ') # Normalize spaces
             .strip
             .truncate(10000) # Limit to 10k chars
    end
    
    def extract_domain_name
      URI.parse(url).host.gsub('www.', '').capitalize
    rescue
      'Untitled'
    end
  end
end
