Gem::Specification.new do |s|
  s.name = "ms-xcalibur"
  s.version = "0.0.1"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://github.com/bahuvrihi/ms-xcalibur/wikis"
  s.platform = Gem::Platform::RUBY
  s.summary = "xcalibur task library"
  s.require_path = "lib"
  s.test_file = "test/tap_test_suite.rb"
  s.rubyforge_project = "bioactive"
  s.has_rdoc = true
  s.add_dependency("tap", "~> 0.10.0")
  s.add_dependency("constants", "~> 0.1.0")
  
  # list extra rdoc files like README here.
  s.extra_rdoc_files = %W{
    MIT-LICENSE
  }
  
  # list the files you want to include here. you can
  # check this manifest using 'rake :print_manifest'
  s.files = %W{
    lib/ms/xcalibur/convert/dta_to_mgf.rb
    lib/ms/xcalibur/convert/raw_to_dta.rb
    lib/ms/xcalibur/convert/raw_to_mgf.rb
    lib/ms/xcalibur/peak_file.rb
    lib/ms/xcalibur/peakify.rb
    tap.yml
  }
end