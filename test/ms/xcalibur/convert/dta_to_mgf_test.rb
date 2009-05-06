require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/xcalibur/convert/dta_to_mgf'

class DtaToMgfTest < Test::Unit::TestCase
  acts_as_tap_test
   
  def test_dta_to_mgf
    t = Ms::Xcalibur::Convert::DtaToMgf.new 
    
    assert_files do |input_files|
      t.output = method_root.path(:output, "output.mgf")
      t.process(*input_files)
    end
  end
  
end