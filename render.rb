#!/usr/bin/env ruby

require "rexml/document"
require "ftools"
include REXML
INKSCAPE = '/usr/bin/inkscape'
SRC = "."

def renderit(file)

    File.makedirs("moblin") unless File.exists?("moblin")

	# Open SVG file.
	svg = Document.new(File.new("#{SRC}/#{file}", 'r'))

	# Go through every layer.
	svg.root.each_element("/svg/g[@inkscape:groupmode='layer']") do |context| 

		context_name = context.attributes.get_attribute("inkscape:label").value  
		
#		puts "Going through layer '" + type_name + "'"
		context.each_element("g") do |icon|
			icon_name = icon.attributes.get_attribute("inkscape:label").value
			icon_id = icon.attributes.get_attribute("id")
			dir = "moblin/scalable/#{context_name}"
			icon_file = "#{dir}/#{icon_name}.svg"
			File.makedirs(dir) unless File.exists?(dir)
			File.copy(file,icon_file)
			puts " >> #{icon_name}"
			cmd = "#{INKSCAPE} -f #{icon_file} --select #{icon_id} --verb=FitCanvasToSelection  --verb=EditInvert --verb=EditDelete --verb=EditSelectAll --verb=SelectionUnGroup --verb=StrokeToPath --verb=FileSave --verb=FileClose > /dev/null 2>&1"
			system(cmd)
			#sadly I have to reopen the icon file to get the id of the bounding box to delete it
			#and do a SelectionUnion
			iconfile = Document.new(File.new(icon_file, 'r'))
			bbox = iconfile.elements["//rect[@inkscape:label='bbox']"]
			bbox.parent.delete(bbox)
			saveagain = File.new(icon_file,'w')
			saveagain.puts iconfile
			saveagain.close
			cmd = "#{INKSCAPE} -f #{icon_file} --verb=EditSelectAll --verb=SelectionUnion --verb=FileSave --verb=FileClose > /dev/null 2>&1"
			system(cmd)
			cmd = "#{INKSCAPE} -f #{icon_file} --vacuum-defs > /dev/null 2>&1"
			system(cmd)
		end
	end
end # End of function.


if (ARGV[0].nil?) #render all SVGs
  puts "Rendering from SVGs in #{SRC}"
  Dir.foreach(SRC) do |file|
    renderit(file) if file.match(/svg$/)
  end
  puts "\nrendered all SVGs"
else #only render the SVG passed
  file = "#{ARGV[0]}.svg"
  if (File.exists?("#{SRC}/#{file}"))
    renderit(file)
    puts "\nrendered #{file}"
  else
    puts "[E] No such file (#{file})"
  end
end
