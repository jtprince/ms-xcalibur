require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'xcalibur/convert/dta_to_mgf'

class Xcalibur::Convert::DtaToMgfTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_dta_to_mgf
    t = Xcalibur::Convert::DtaToMgf.new 
    
    assert_files do |input_files| 
      t.execute(method_filepath(:output, "output.mgf"), *input_files)
    end
  end
  
end