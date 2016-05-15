require "yaml"
require "erb"
require_relative "./markdown"

class Post
  attr_reader :title, :raw_body
  def initialize(title:, date:, raw_body:, filename:)
    @title = title
    @date = date
    @raw_body = raw_body
    @filename = filename
  end

  def slug
    File.basename(@filename, ".yml")
  end

  def date
    @date.strftime("%Y %b %-d")
  end

  def body
    SyntaxHighlightedMarkdown.render(@raw_body)
  end

  def output_filepath
    File.join(output_directory, "index.html")
  end

  def output_directory
    File.join(
      @date.year.to_s,
      @date.month.to_s,
      @date.day.to_s,
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
      raw_body: file_contents.split("---\n").last
    )
  end

  def self.load_posts(glob)
    Dir.glob(glob).map do |path|
      load_post(path)
    end
  end
end
