Gem::Specification.new do |spec|
  spec.name          = "dockerize-rails"  # The name can remain, but make sure it's framework-agnostic
  spec.version       = "0.1.0"
  spec.authors       = ["Gaurav Balodi"]
  spec.email         = ["gaurav.balodi2@gmail.com"]
  spec.summary       = "A gem that helps generate Dockerfiles for Ruby applications."
  spec.description   = "This gem creates a Dockerfile and configures development environments for Ruby apps."
  spec.homepage      = "http://example.com/dockerize-rails"
  spec.license       = "MIT"

  # Files to include in the gem package
  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]

  # Instead of Rails, provide dependencies that would be needed across frameworks
  # spec.add_runtime_dependency "docker-api", "~> 1.39"
  
  # Development dependencies (for testing, etc.)
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end


# Gem::Specification.new do |spec|
#   spec.name          = "dockerize-rails"
#   spec.version       = "0.1.0"
#   spec.authors       = ["Gaurav Balodi"]
#   spec.summary       = "A gem that helps generate Dockerfiles for Ruby applications."
#   spec.description   = "This gem creates a Dockerfile and configures development environments for Ruby apps."
#   spec.homepage      = "http://example.com/dockerize-rails"
#   spec.license       = "MIT"
#   spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]
#   spec.add_runtime_dependency "docker-api", "~> 1.39"
#   spec.add_development_dependency "minitest", "~> 5.0"
#   spec.add_development_dependency "rake", "~> 13.0"
# end
