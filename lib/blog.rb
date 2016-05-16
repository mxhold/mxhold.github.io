require "erb"

module Blog
  module ViewHelpers
    def path_to(path_relative_to_root)
      nesting_level = Pathname.new(@output_dir).ascend.to_a.size
      if nesting_level == 1
        path_relative_to_root
      else
        File.join(nesting_level.times.map { ".." }, path_relative_to_root)
      end
    end
  end

  class Renderer
    include ViewHelpers

    def initialize(variables)
      variables.each do |name, value|
        instance_variable_set(name, value)
      end
    end

    def render(template)
      ERB.new(File.read(template)).result(binding)
    end
  end

  def self.render(template, variables)
    Renderer.new(variables).render(template)
  end

  def self.render_with_layout(template, variables)
    render(
      "templates/layout.html.erb",
      :@content => render(template, variables),
      :@output_dir => variables[:@output_dir],
    )
  end

  def self.render_to_file_with_layout(template, filepath, variables)
    variables[:@output_dir] = File.dirname(filepath)
    File.open(filepath, "w") do |file|
      file.write(render_with_layout(template, variables))
    end
  end
end
