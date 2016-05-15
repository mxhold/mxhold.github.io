require "erb"

page = ARGV.shift

context = File.read("#{page}.rb")
template = File.read("#{page}.html.erb")

eval(context)

puts ERB.new(template).result(binding)
