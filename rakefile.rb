require 'rubygems'
require 'bundler/setup'
require 'zip/zip'
require 'version/version_task'
require 'version'

#############################################
# Utility methods
#############################################

class String
	def /(join)
		File.join(self, join)
	end
end

def get_classes(path)
	Dir.chdir(path) do
		FileList["**/*.as"].pathmap("%X").map do |f|
			f.gsub(/^\.\//, '').gsub(/[\/\\]/, '.')
		end
	end
end

def run(command, abort_on_failure = true)
	command = command.gsub('/', '\\') if is_windows?
	output = ""

	puts "#{command}"
	IO.popen("#{command} 2>&1") do |proc|
		while !proc.closed? && (line = proc.gets)
			puts "> #{line}"
			output << line
			yield line if block_given?
		end
	end

	if $?.exitstatus != 0
		msg = "Operation exited with status #{$?.exitstatus}"
		if abort_on_failure
			abort msg
		else
			puts msg
		end	
	end
	#log $?.exitstatus

	return output
end

def current_version
	Version.current(Rake.original_dir/PROJECT[:version_file]) || "0.0.0"
end

def is_windows?
	require 'rbconfig'
	RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
end

#############################################
# Config
#############################################

CONFIG = {
	:license_src => ".."/".."/"LICENSE",
	:license_dest => "license.txt",
}

PROJECT[:version_file] 	= ".version" 	if PROJECT[:version_file].nil?
PROJECT[:src_dir] 		= "src" 		if PROJECT[:src_dir].nil?

#create constants so it's quicker to get project settings
BIN = PROJECT[:bin_dir] || "bin"
SWC = BIN/"#{PROJECT[:name]}.swc"
SWC_VERSIONED = BIN/"#{PROJECT[:name]}-#{current_version}.swc"
ZIP = BIN/"#{PROJECT[:name]}-#{current_version}.zip"

#############################################
# Tasks
#############################################

task :default => :build

desc "Compile the swc"
task :build => SWC

desc "Package the project into a zip"
task :package => ZIP

directory BIN

file SWC => FileList[BIN, PROJECT[:src_dir]/"**"/"*.as"] do
	run "#{COMPC} -load-config+=compc_config.xml -output #{SWC}"
end

file PROJECT[:version_file] do
	Rake::Task["version:create"].execute
	#abort "rake aborted!\nVersion file missing and had to be created"
end

file SWC_VERSIONED => [SWC, PROJECT[:version_file]] do
	cp SWC, SWC_VERSIONED
end

file ZIP => SWC_VERSIONED do
	rm_q ZIP rescue nil

	Zip::ZipFile.open(ZIP, Zip::ZipFile::CREATE) do |zip|
		zip.add(CONFIG[:license_dest], CONFIG[:license_src])
		zip.add("#{PROJECT[:name]}-#{current_version}.swc", SWC_VERSIONED)
	end

	puts "zip #{ZIP}"
end

Rake::VersionTask.new do |task|
	task.filename = PROJECT[:version_file]
end

desc "Remove package results & temporary build artifacts"
task :clean do
	list = FileList.new
	list.include(BIN/"*");
	list.exclude(SWC)
	list.each { |fn| rm_r fn rescue nil }
end

desc "Remove all build & package results"
task :clobber => [:clean] do
	list = FileList.new
	list.include(SWC)
	list.each { |fn| rm_r fn rescue nil }
end

#############################################
# Find Flex SDK
#############################################

[
	ENV['FLEX_HOME'],
	'C:\develop\sdk\flex_sdk_4.6.0.23201',
	'C:\develop\sdk\flex_sdk_4.5.1.21328'
].each do |path|
	if path != nil && File.exists?(path)
		FLEX_HOME = path
		MXMLC 	= FLEX_HOME/'bin'/'mxmlc'
		COMPC 	= FLEX_HOME/'bin'/'compc'
		AMXMLC 	= FLEX_HOME/'bin'/'amxmlc'
		ACOMPC 	= FLEX_HOME/'bin'/'acompc'
		ADT 	= FLEX_HOME/'bin'/'adt'
		ADL 	= FLEX_HOME/'bin'/'adl'
		ASDOC 	= FLEX_HOME/'bin'/'asdoc'
		break
	end
end

if defined? FLEX_HOME
	puts "Using Flex SDK at #{FLEX_HOME}"
else
	abort "\nrake aborted!\nCould not find Flex SDK"
end