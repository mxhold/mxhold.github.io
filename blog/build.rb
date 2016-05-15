require "fileutils"

posts = Post.load_posts("posts/*")

posts.each do |post|
  FileUtils.mkdir_p(post.output_directory)
  File.open(post.output_filepath, "w") do |file|
    file.write(post.render)
  end
end
