#!/usr/bin/ruby -wKU

require 'optparse'

##### Default values
OUTPUT_FOLDER = "/home/ebruning/itunes/"
INPUT_FOLDER = "./"
PRESETS = "AppleTV 2"
LOGFILE = ""

$start_time = Time.now

def main
  puts ""
  options = parse_arguments

  validate_arguments(options)

  input_folder = options[:input_folder] != "" ? set_input_directory(options[:input_folder]) : INPUT_FOLDER
  output_folder = options[:output_folder] != "" ? set_output_directory(options[:output_folder]) : OUTPUT_FOLDER
  preset = options[:preset] != "" ? options[:preset] : PRESETS

  if options[:filename] != ""
    convert_single_file(output_folder, options[:filename], preset)
  else
    parse_folder(input_folder, output_folder, preset)
  end


  #p "input_folder -> %s" % input_folder
  #p "output_folder -> %s" % output_folder
  #p "preset -> %s" % preset
end

def convert_single_file(output_folder, file, preset)
  if !File.exists?(file)
    puts "File not found"
    exit
  end
  puts "Converting %s => %s" % [ file, convert_name(output_folder, file) ]
  convert_movie(output_folder, file, preset)
  print_status(1)
end

def set_input_directory(dir)
  if !File.exists?(dir)
    puts "Input folder doesn't exists"
    exit
  end

  return dir
end

def set_output_directory(dir)
  if !File.exists?(dir)
    Dir.mkdir(dir)
  end

  return dir
end

#TODO: Better error handling
def validate_arguments(options)
  if options[:filename] != "" and options[:input_folder] != ""
    puts "Cannot specify a directory and file at the same time"
    exit
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

def convert_name(output_folder, name)
	return output_folder + File.basename(name, File.extname(name)) + ".m4v"
end

def print_status(count)
	puts ""
	puts "Conversion started: " + $start_time.to_s
	puts "Movies converted:   " + count.to_s
	puts "Time ellapsed:      " + get_elapsed_time.to_s + " seconds"
	puts ""
end

def get_elapsed_time()
	(Time.now - $start_time)/360
end

def convert_movie(output_folder, file, preset)
#  system("HandBrakeCLI -i " + input + " -o " + convert_name(input) + " --preset \"AppleTV 2\" >/dev/null 2>&1")
  system("HandBrakeCLI -i %s -o %s --preset %s >/dev/null 2>&1" % [file, convert_name(output_folder, file), preset])
end

def parse_folder(input_folder, output_folder, preset)
  count = 1
  movies = Dir.glob(File.join(input_folder, "*"))
  movies.each do |movie|
  	if File.file?(movie) == true
  		if File.exists?(convert_name(output_folder, movie)) == false
  			puts "[%02d/%02d] Converting %s => %s" % [ count, movies.count, movie, convert_name(output_folder, movie) ]
  			convert_movie(output_folder, movie, preset)
  			count = count + 1
  		else
  			puts "Skipping %s (already exsist)" % movie
  		end
  	end
  end

  print_status(movies.count)
end

main()