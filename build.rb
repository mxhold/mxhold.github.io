require "fileutils"
require_relative "./lib/post"
require_relative "./lib/blog"

posts = Dir.glob("posts/*").map do |path|
  Post.load(path)
end

posts.each do |post|
  FileUtils.mkdir_p(post.output_dir)

  Blog.render_to_file_with_layout(
    "templates/post.html.erb",
    post.output_filepath,
    :@post => post,
  )
  puts "Created #{post.output_filepath}"
end

Blog.render_to_file_with_layout(
  "templates/index.html.erb",
  "./index.html",
  :@posts => posts,
)
puts "Created index.html"
