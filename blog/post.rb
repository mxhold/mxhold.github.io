require "yaml"
require_relative "./markdown"

class Post
  attr_reader :title
  def initialize(title:, date:, body:, filename:)
    @title = title
    @date = date
    @body = body
    @filename = filename
  end

  def slug
    File.basename(@filename, ".yml")
  end

  def date
    @date.strftime("%Y %b %-d")
  end

  def render
    SyntaxHighlightedMarkdown.render(@body)
  end

  def output_filepath
    File.join(output_directory, "index.html")
  end

  def output_directory
    File.join(
      @date.year,
      @date.month,
      @date.day,
      slug
    )
  end

  def self.load_post(filename)
    file_contents = File.read(filename)
    metadata = YAML.load(file_contents)

    Post.new(
      filename: filename,
      title: metadata["title"],
      date: metadata["date"],
      body: file_contents.split("---\n").last
    )
  end

  def self.load_posts(glob)
    Dir.glob(glob).map do |path|
      load_post(path)
    end
  end
end
