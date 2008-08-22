require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/xcalibur/convert/raw_to_mgf'

class RawToMgfTest < Test::Unit::TestCase
  acts_as_tap_test :directories => {:data => 'output'}
  
  unless match_platform?("mswin")
    skip_test("Only available on Windows.")
  end
  
  def test_raw_to_mgf
    t = MS::Xcalibur::Convert::RawToMgf.new :merge_file => method_filepath(:output, "merge.mgf")

    assert_files do |input_files| 
      t.enq(*input_files)
      app.run
      app.results(t.exit_point)
    end
  end
  
end