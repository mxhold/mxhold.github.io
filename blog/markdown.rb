require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

class HTML < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet
end

module SyntaxHighlightedMarkdown
  def self.render(markdown)
    Redcarpet::Markdown.new(HTML, fenced_code_blocks: true).render(markdown)
  end
end
