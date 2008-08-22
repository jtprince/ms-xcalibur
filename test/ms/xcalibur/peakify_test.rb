require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/xcalibur/peakify'

class PeakifyTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  def test_peakify
    t = MS::Xcalibur::Peakify.new 
    assert_files do |input_files|
      input_files.each {|file| t.enq(file)}
      
      with_config :directories => {:data => 'output'} do 
        app.run
      end
      
      app.results(t)
    end
  end
  
end