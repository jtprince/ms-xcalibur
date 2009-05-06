require 'tap/tasks/file_task'
require 'constants'

module Ms
  module Xcalibur
    module Convert
      
      # :startdoc::task convert dta files to mgf format
      #
      # Converts a set of dta files (Sequest format) into an mgf (Mascot format) 
      # file.  By default the mgf file is printed to $stdout, so redirection is
      # a good way to save the results.
      #
      #   % tap run -- dta_to_mgf ... > results.mgf
      #
      # Alternatively, specify the output file using the output configuration.
      #
      # === Conversion
      #
      # The dta -> mgf conversion is straightforward:
      #
      # dta format:
      #   [input_file.dta]
      #   353.128 1 
      #   85.354 2.2
      #   87.302 2.8
      #   ...
      #
      # mgf format:
      #   [output_file.mgf]
      #   BEGIN IONS
      #   TITLE=input_file
      #   CHARGE=1
      #   PEPMASS=<calculated>
      #   85.354 2.2
      #   87.302 2.8
      #   ...
      #   END IONS
      #
      # The first line of the dta file specifies the M+H (mh) and charge state (z) of 
      # the  precursor ion.  To convert this to PEPMASS, use (mh + (z-1) * H)/ z) where
      # H is the mass of a proton, ie hydrogen - electron.  The mass of a proton is
      # calculated from the {constants}[bioactive.rubyforge.org/constants] gem to be 
      # ~ 1.007276 Da
      #
      class DtaToMgf < Tap::Tasks::FileTask
        include Constants::Libraries

        # Returns the unrounded mass of a proton (H - e) as calculated
        # from the {constants}[bioactive.rubyforge.org/constants] gem.
        config :proton_mass, Element['H'].mass - Particle['Electron'].mass, &c.num_or_nil # Specify the proton mass
        config :output, $stdout, &c.io(:<<, :binmode) # The output file
        
        def process(*dta_files)
          prepare(output) if output.kind_of?(String)
          open_io(output, 'w') do |target|
            target.binmode
            
            log :convert, "#{dta_files.length} dta files"
            dta_files.each do |file|
              app.check_terminate
              lines = File.read(file).split(/\r?\n/)

              # get the mh and z
              mh, z = lines.shift.split(/\s+/)
              mh = mh.to_f
              z = z.to_i

              # add a trailing empty line
              lines << ""

              # make the output
              target << %Q{BEGIN IONS
TITLE=#{File.basename(file)}
CHARGE=#{z}+
PEPMASS=#{(mh + (z-1) * proton_mass)/ z}
#{lines.join("\n")}
END IONS

}
            end
          end
          output
        end
      end
    end
  end
end
