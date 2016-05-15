require "fileutils"
require_relative "./post"

def path_to(relative_path)
  nesting_level = Pathname.new(@output_directory).ascend.to_a.size
  if nesting_level == 1
    relative_path
  else
    File.join(nesting_level.times.map { ".." }, relative_path)
  end
end

posts = Post.load_posts("posts/*")

layout_template = File.read("templates/layout.html.erb")
post_template = File.read("templates/post.html.erb")
index_template = File.read("templates/index.html.erb")

posts.each do |post|
  FileUtils.mkdir_p(post.output_directory)
  @post = post
  @output_directory = post.output_directory

  @content = ERB.new(post_template).result(binding)
  page = ERB.new(layout_template).result(binding)

  File.open(post.output_filepath, "w") do |file|
    file.write page
  end
end

@posts = posts

@output_directory = "."
@content = ERB.new(index_template).result(binding)
index_page = ERB.new(layout_template).result(binding)

File.open("index.html", "w") do |file|
  file.write index_page
end
