require "date"

class Post
  attr_reader :title, :url
  def initialize(title:, url:, date:)
    @title = title
    @url = url
    @date = date
  end

  def date
    @date.strftime("%Y %b %-d")
  end
end

@posts = [
  Post.new(
    title: "Rust gives you Options and Results",
    url: "rust-gives-you-options-and-results.html",
    date: Date.parse("2016-05-14"),
  ),
  Post.new(
    title: "Blogs I like",
    url: "blogs-I-like.html",
    date: Date.parse("2016-05-14"),
  ),
]
