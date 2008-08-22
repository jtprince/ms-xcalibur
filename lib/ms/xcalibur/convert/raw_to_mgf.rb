require 'ms/xcalibur/convert/raw_to_dta'
require 'ms/xcalibur/convert/dta_to_mgf'

module MS
  module Xcalibur
    module Convert
      # :startdoc::manifest convert RAW files to mgf format
      # Extracts spectra from a .RAW file and formats them as mgf (Mascot
      # Generic Format).  RawToMgf is a workflow that uses the RawToDta
      # and DtaToMgf tasks, and can be configured through these tasks
      # using the following configuration files:
      #
      #   config/xcalibur/convert
      #   |- raw_to_mgf.yml               # configures RawToMgf
      #   `- raw_to_mgf
      #    |- raw_to_dta.yml              # configures RawToDta
      #    `- dta_to_mgf.yml              # configures DtaToMgf
      #
      # Mgf files are named after the RAW file they represent; the group
      # merge file is named 'merge.mgf' although an alternate merge file
      # name can be specified in the options.
      #
      class RawToMgf < Tap::Workflow

        config :merge_file, 'merge.mgf'            # the group merge file
        config :merge_individual, true, &c.switch  # merge the dta's for each RAW file
        config :merge_group, true, &c.switch       # merge the dta's for all RAW files
        config :remove_dta_files, true, &c.switch  # clean up dta files upon completion

        def workflow 
          # Define the workflow entry and exit points,
          # as well as the workflow logic.

          raw_to_dta = Xcalibur::Convert::RawToDta.new
          dta_to_mgf = Xcalibur::Convert::DtaToMgf.new

          dta_dirs = []
          n_inputs = nil
          self.entry_point = Tap::Task.new do |task, *input_files|
            n_inputs = input_files.length
            input_files.each do |input_file|
              dta_dir = File.basename(input_file).chomp(File.extname(input_file))
              dta_dirs << dta_dir
              raw_to_dta.enq(input_file, dta_dir)
            end
          end

          group_results = []
          raw_to_dta.on_complete do |_result|
            if merge_individual
              input_file = _result._original[0]
              output_file = File.join( File.dirname(merge_file), File.basename(input_file).chomp(File.extname(input_file)) + ".mgf")
              dta_to_mgf.enq(output_file, *_result._expand)
            end

            # collect _results to determine when all the input
            # files have been processed by raw_to_dta
            group_results << _result

            # When all the input files have been converted, merge the
            # group and enque a task to cleanup the dta files, as specified.
            if group_results.length == n_inputs
              if merge_group
                all_results = group_results.collect {|_result| _result._expand }.flatten
                dta_to_mgf.enq(merge_file, *all_results)
              end

              if remove_dta_files
                cleanup = Tap::Task.new do |task, raw_dir|           
                  task.log :rm, raw_dir

                  # take this stepwise to be a little safer...
                  FileUtils.rm Dir.glob(raw_dir + "/*.dta")
                  FileUtils.rm ["#{raw_dir }/lcq_dta.txt", "#{raw_dir }/lcq_profile.txt"]
                  FileUtils.rmdir raw_dir
                end
                dta_dirs.each {|dir| cleanup.enq(dir)}
              end
            end
          end

          self.exit_point = dta_to_mgf
        end
      end
    end
  end
end