module PortableText
  class Converter
    # Helper to render marks
    def self.render_marks(marks, mark_defs, text)
      marks.reduce(text) do |content, mark|
        case mark
        when 'emphasis'
          "<em>#{content}</em>"
        else
          if (mark_def = mark_defs.find { |md| md['_key'] == mark })
            # Handle custom annotations like links
            case mark_def['_type']
            when 'link'
              "<a href=\"#{mark_def['href']}\">#{content}</a>"
            else
              content
            end
          else
            content
          end
        end
      end
    end

    # Main function to convert Portable Text to HTML
    def self.to_html(portable_text)
      html_output = ""

      portable_text.each do |block|
        case block['_type']
        when 'block'
          style = block['style'] || 'p' # Default to paragraph
          html_output += "<#{style}>"

          block['children'].each do |child|
            text_content = child['text']
            if child['marks'] && !child['marks'].empty?
              mark_defs = block['markDefs'] || []
              text_content = render_marks(child['marks'], mark_defs, text_content)
            end
            html_output += text_content
          end

          html_output += "</#{style}>"
        when 'image'
          html_output += "<img src=\"#{block['asset']['_ref']}\" alt=\"\">"
        when 'code'
          html_output += "<pre><code class=\"language-#{block['language']}\">#{block['code']}</code></pre>"
        end
      end

      html_output
    end
  end
end

# Example usage
# portable_text_json = 'YOUR PORTABLE TEXT JSON HERE'
# portable_text = JSON.parse(portable_text_json)
# html = PortableText::Converter.to_html(portable_text)
# puts html