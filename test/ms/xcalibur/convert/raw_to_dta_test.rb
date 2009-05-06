require File.join(File.dirname(__FILE__), '../../../tap_test_helper.rb') 
require 'ms/xcalibur/convert/raw_to_dta'

class RawToDtaTest < Test::Unit::TestCase
  acts_as_tap_test
  acts_as_subset_test
  
  unless match_platform?("mswin")
    skip_test("Only available on Windows.")
  end
  
  condition(:extract_msn_exists) do 
    File.exists? Ms::Xcalibur::Convert::RawToDta.configurations[:extract_msn].default
  end
  
  attr_accessor :t
  
  def setup
    super
    @t = Ms::Xcalibur::Convert::RawToDta.new 
  end
  
  #
  # cmd tests
  #
  
  def test_default_cmd
    assert_equal "\"C:\\Xcalibur\\System\\Programs\\extract_msn.exe\" -M1.4 -S1 -G1 -I0 -R3 -r5 \"C:\\path\\to\\file.RAW\"", t.cmd("C:\\path\\to\\file.RAW")
  end

  def test_cmd_with_variations
    t.extract_msn = "/path/to/extract_msn.exe"
    t.minimum_signal_to_noise = 0
    t.write_zta_files = true
    t.perform_charge_calculations = false
    t.subsequence = "blahblah"
    t.template_file = "/path/to/folder/.././template file.txt"
    assert_equal "\"C:\\path\\to\\extract_msn.exe\" -M1.4 -S1 -G1 -I0 -Yblahblah -Z -O\"C:\\path\\to\\template file.txt\" -R0 -r5 \"C:\\path\\to\\file.RAW\"", t.cmd("/path/folder/.././to/file.RAW")
  end

  #
  # process tests
  #
  
  def input_file
    ctr.path(:root, "T29K_620.9@cid33_080703140516.raw")
  end
  
  def test_raw_to_dta_with_default_options
    condition_test(:extract_msn_exists) do
      assert_files do |x|
        t.output_dir = method_root[:output]
        t.process(input_file)
      end
    end
  end
  
  def test_raw_to_dta_with_alt_options
    condition_test(:extract_msn_exists) do
      t.lower_MW = 1500
      
      assert_files do |x|
        t.output_dir = method_root[:output]
        t.process(input_file)
      end
    end
  end
  
end