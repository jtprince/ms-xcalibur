require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/xcalibur/peakify'

class PeakifyTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_peakify
    t = Ms::Xcalibur::Peakify.new 
    assert_files do |input_files|
      input_files.collect do |file|
        t.output = method_root.translate(file, :input, :output)
        t.process(file)
      end
    end
  end
  
end