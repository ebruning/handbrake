#!/usr/bin/ruby -wKU

require 'optparse'

##### Default values
OUTPUT_FOLDER = "/home/ebruning/itunes/"
INPUT_FOLDER = "./"
PRESETS = "AppleTV 2"
LOGFILE = ""
EXTENSION = ".m4v"

$start_time = Time.now

def main
  puts ""
  options = parse_arguments

  begin
    validate_arguments(options)

    output_folder = options[:output_folder] != "" ? set_output_directory(options[:output_folder]) : OUTPUT_FOLDER
    preset = options[:preset] != "" ? options[:preset] : PRESETS

    if options[:filename] != ""
      convert_single_file(output_folder, options[:filename], preset)
    else
      input_folder = options[:input_folder] != "" ? set_input_directory(options[:input_folder]) : INPUT_FOLDER
      convert_folder(input_folder, output_folder, preset)
    end
  rescue => e
    p "[ERROR]: %s" % e.message
  end
end

def set_input_directory(dir)
  if !File.exists?(dir)
    raise IOError, "Input folder doesn't exists"
  end

  return dir
end

def set_output_directory(dir)
  if !File.exists?(dir)
    Dir.mkdir(dir)
  end

  return dir
end

def validate_arguments(options)
  if options[:filename] != "" and options[:input_folder] != ""
    raise ArgumentError, "Cannot specify a directory and file at the same time"
  end
end

def parse_arguments
    options = {}
    OptionParser.new do |opts|
    opts.banner = "Usage: handbrake.rb [options]"

    options[:input_folder] = ""
    opts.on( '-i', '--input DIR', "Input folder" ) do|i|
      options[:input_folder] = i
    end

    options[:output_folder] = ""
    opts.on( '-o', '--output DIR', "Output folder" ) do|i|
      options[:output_folder] = i
    end

    options[:preset] = ""
    opts.on( '-p', '--preset PRESET', "Handbrake preset name" ) do|i|
      options[:preset] = i
    end

    options[:filename] = ""
    opts.on( '-f', '--file FILE', "File name to convert" ) do|i|
      options[:filename] = i
    end
  end.parse!

  return options
end

def convert_name(name)
  return File.basename(name, File.extname(name)) + EXTENSION
end

def get_output_folder_name(output_folder, name)
  return File.join(output_folder, convert_name(name))
end

def print_status(count)
	puts ""
	puts "Conversion started: %s" % $start_time.to_s
	puts "Movies converted:   %s" % count.to_s
	puts "Time ellapsed:      %s" % get_elapsed_time
	puts ""
end

def get_elapsed_time()
  mm, ss = ((Time.now - $start_time).to_f).divmod(60)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)

	return "%d days %d hours %d minutes %d seconds" % [dd, hh, mm, ss]
end

def convert_movie(output_folder, file, preset)
  system("HandBrakeCLI -i %s -o %s --preset %s >/dev/null 2>&1" % [file, get_output_folder_name(output_folder, file), preset])
  return get_error_code($? >> 8)
end

def get_error_code(code)
  return code == 0 ? "Completed" : "Failed"
end

def convert_single_file(output_folder, file, preset)
  if !File.exists?(file)
    raise IOError, "Movie file to convert not found"
  end
  puts "Converting %s => %s" % [ file, get_output_folder_name(output_folder, file) ]
  puts "(%s)" % convert_movie(output_folder, file, preset)
  print_status(1)
end

def convert_folder(input_folder, output_folder, preset)
  count = 1
  movies = Dir.glob(File.join(input_folder, "*"))
  movies.each do |movie|
  	if File.file?(movie) == true
  		if File.exists?(get_output_folder_name(output_folder, movie)) == false
  			puts "[%02d/%02d] Converting %s => %s" % [ count, movies.count, movie, get_output_folder_name(output_folder, movie) ]
  			puts "(%s)" % convert_movie(output_folder, movie, preset)
  			count = count + 1
  		else
  			puts "Skipping %s (output file already exsist)" % movie
  		end
  	end
  end

  print_status(movies.count)
end

main()
