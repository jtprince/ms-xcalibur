Gem::Specification.new do |s|
  s.name = "ms-xcalibur"
  s.version = "0.3.0"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://mspire.rubyforge.org/projects/ms-xcalibur/"
  s.platform = Gem::Platform::RUBY
  s.summary = "An Mspire library supporting Xcalibur."
  s.require_path = "lib"
  s.rubyforge_project = "mspire"
  s.has_rdoc = true
  s.add_dependency("tap", ">= 0.17.0")
  s.add_dependency("tap-tasks", ">= 0.2.0")
  s.add_dependency("constants", ">= 0.1")
  s.add_development_dependency("tap-test", ">= 0.1.0")
  
  # list extra rdoc files like README here.
  s.extra_rdoc_files = %W{
    History
    README
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake print_manifest'
  s.files = %W{
    lib/ms/xcalibur/convert/dta_to_mgf.rb
    lib/ms/xcalibur/convert/raw_to_dta.rb
    lib/ms/xcalibur/peak_file.rb
    lib/ms/xcalibur/peakify.rb
    tap.yml
  }
end