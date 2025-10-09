require 'nokogiri'
require 'open-uri'

module Saturn
  class UrlScraperService
    attr_reader :url
    
    def initialize(url)
      @url = url
    end
    
    def scrape
      begin
        # Fetch the HTML content
        html = URI.open(url, 
          'User-Agent' => 'Mozilla/5.0 (compatible; AISaturn/1.0)',
          read_timeout: 10
        ).read
        
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
      rescue OpenURI::HTTPError => e
        {
          success: false,
          error: "HTTP hatası: #{e.message}",
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
