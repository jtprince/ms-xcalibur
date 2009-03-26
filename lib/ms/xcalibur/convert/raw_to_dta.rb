module Ms
  module Xcalibur
    module Convert
      # :startdoc::manifest convert RAW files to dta format
      # Converts a .RAW file to dta files using extract_msn.exe 
      #
      # extract_msn.exe is an Xcalibur/BioWorks tool that extracts spectra from .RAW
      # files into .dta (Sequest) format and must be installed for RawToDta to work.
      # RawToDta was developed against extract_msn version 4.0.  You can check if
      # extract_msn is installed at the default location, as well as determine the  
      # version of your executable using:
      #
      #   % tap run -- xcalibur/convert/raw_to_dta  --extract_msn_help
      #
      class RawToDta < Tap::FileTask
        config :extract_msn, 'C:\Xcalibur\System\Programs\extract_msn.exe' # the full path to the extract_msn executable
        config :first_scan, nil, :short => :F, &c.integer_or_nil
        config :last_scan, nil, :short => :L, &c.integer_or_nil
        config :lower_MW, nil, :short => :B, &c.num_or_nil
        config :upper_MW, nil, :short => :T, &c.num_or_nil
        config :precursor_mass_tol, 1.4, :short => :M, &c.num
        config :num_allowed_intermediate_scans_for_grouping, 1, :short => :S, &c.integer
        config :charge_state, nil, :short => :C, &c.integer_or_nil
        config :num_required_group_scans, 1, :short => :G, &c.integer_or_nil
        config :num_ions_required, 0, :short => :I, &c.integer_or_nil
        config :intensity_threshold, nil, :short => :E, &c.integer_or_nil
        config :use_unified_search_file, nil, :short => :U, &c.flag
        config :subsequence, nil, :short => :Y
        config :write_zta_files, nil, :short => :Z, &c.flag
        config :perform_charge_calculations, nil, :short => :K, &c.flag
        config :template_file, nil, :short => :O
        config :options_string, nil, :short => :A
        config :minimum_signal_to_noise, 3, :short => :R, &c.num
        config :minimum_number_of_peaks, 5, :short => :r, &c.integer
        config :output_dir, nil, &c.string_or_nil
        
        config_attr(:extract_msn_help, nil, :arg_type => :flag) do |value|  # Print the extract_msn help         
          if value
            sh(extract_msn)
            exit
          end
        end

        CONFIG_MAP = [
          [:first_scan, 'F'],
          [:last_scan, 'L'],
          [:lower_MW, 'B'],
          [:upper_MW, 'T'],
          [:precursor_mass_tol, 'M'],
          [:num_allowed_intermediate_scans_for_grouping, 'S'],
          [:charge_state, 'C'],
          [:num_required_group_scans, 'G'],
          [:num_ions_required, 'I'],
          [:output_path, 'D'],
          [:intensity_threshold, 'E'],
          [:use_unified_search_file, 'U'],
          [:subsequence, 'Y'],
          [:write_zta_files, 'Z'],
          [:perform_charge_calculations, 'K'],
          [:template_file, 'O'],
          [:options_string, 'A'],
          [:minimum_signal_to_noise, 'R'],
          [:minimum_number_of_peaks, 'r']
        ]

        # Expands the input path and converts all forward slashes (/) 
        # to backslashes (\) to make it into a Windows-style path.
        def normalize(path)
          File.expand_path(path).gsub(/\//, "\\")
        end

        # Formats command options for extract_msn.exe using the current configuration.
        # Configurations are mapped to their single-letter keys using CONFIG_MAP.
        #
        # A default output_dir can be specified for when config[:output_path] is not 
        # specified.
        def cmd_options(output_dir=nil)
          options = CONFIG_MAP.collect do |key, flag|
            value = (flag == "D" ? output_dir : config[key])
            next unless value

            # formatting consists of stringifying the value argument, or
            # in escaping the value if the arguement is a path
            formatted_value = case key
            when :use_unified_search_file, :perform_charge_calculations, :write_zta_files
              "" # no argument
            when :output_path, :template_file 
              # path argument, escape
              "\"#{normalize value}\""  
            else 
              # number or string, simply stringify
              value.to_s
            end

            "-#{flag}#{formatted_value}"
          end

          options.compact.join(" ")
        end

        # Formats the extract_msn.exe command using the specified input_file,
        # and the current configuration.  A default output directory can be 
        # specified using output_dir; it will not override a configured output
        # directory.
        #
        # Note that output_dir should be an EXISTING filepath or relative 
        # filepath.   execute_msn.exe will not generate .dta files if the  
        # output_dir doesn't exist.
        def cmd(input_file, output_dir=nil)
          args = []
          args << "\"#{normalize extract_msn}\""
          args << cmd_options(output_dir)
          args << "\"#{normalize input_file}\""

          args.join(' ')
        end

        def process(input_file)
          extname = File.extname(input_file)
          raise "Expected .RAW file: #{input_file}" unless  extname =~ /\.RAW$/i

          # Target the output to a directory with the same basename 
          # as the raw file, unless otherwise specified.
          output_dir = self.output_dir || input_file.chomp(File.extname(input_file))
          current_dta_files = dta_files(output_dir)
          if uptodate?(current_dta_files, input_file)
            log_basename :uptodate, input_file
            current_dta_files
          else
            mkdir(output_dir)
            command = cmd(input_file, output_dir)

            log :sh, command
            if app.quiet
              capture_sh(command, true)
            else
              sh(command)
              puts ""  # add extra line to make logging nice
            end
            
            dta_files(output_dir)
          end
        end
        
        def dta_files(output_dir)
          lcq_dta = File.join(output_dir, 'lcq_dta.txt')
          
          dta_files = []
          File.read(lcq_dta).scan(/Datafile:\s(.*?\.dta)\s/) do |dta_file|
            dta_files << File.join(output_dir, dta_file)
          end if File.exists?(lcq_dta)
          
          dta_files
        end
        
      end
    end
  end
end