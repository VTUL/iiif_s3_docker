#!/usr/bin/env ruby

require 'aws-sdk'
require 'fileutils'
require 'iiif_s3'
require 'open-uri'
require 'optparse'
require_relative '../../lib/iiif_s3/manifest_override'
IiifS3::Manifest.prepend IiifS3::ManifestOverride

@supported_img_types = [".bmp", ".gif", ".jpg", ".jpeg", ".png", ".tif", ".tiff"]

# Create directories on local disk for manifests/tiles to upload them to S3
def create_directories(path)
  FileUtils.mkdir_p(path) unless Dir.exists?(path)
end

# Get label and description metadata from csv file
def get_metadata(csv_url, id)
  begin
    open(csv_url) do |u|
      csv_file_name = File.basename(csv_url)
      csv_file_path = "#{@config.output_dir}/#{csv_file_name}"
      File.open(csv_file_path, 'wb') { |f| f.write(u.read) }
      CSV.read(csv_file_path, 'r:bom|utf-8', headers: true).each do |row|
        if row.header?("identifier")
          if row.field("identifier") == id
            return row.field("title"), row.field("description")
          end
        else
          puts "No identifier header found"
          return
        end
      end
      puts "No matching identifier found"
    end
  rescue StandardError => e
    puts "An error occurred processing #{csv_url}: #{e.message}"
  end
end

def get_s3_filelist_for_item(s3, options)
  resp = s3.list_objects_v2({
    bucket: options[:source_bucket],
    prefix: options[:image_folder]
  })
  return resp.contents.map{ |f| f.key }
end

def add_image(file, id, idx)
  name = File.basename(file, File.extname(file))
  page_num = idx + 1
  label, description = get_metadata(@csv_url, id)
  obj = {
    "path" => "#{file}",
    "id"       => id,
    "label"    => label,
    "is_master" => page_num == 1,
    "page_number" => page_num,
    "is_document" => false,
    "description" => description,
  }

  obj["section"] = "p#{page_num}"
  obj["section_label"] = "Page #{page_num}"
  @data.push IiifS3::ImageRecord.new(obj)
end

def is_image_file?(file)
  # this needs to be replaced with some mime-type guessing gem
  is_img = @supported_img_types.include?(File.extname(file).downcase)
end

def s3_exists?(s3, bucket, path)
  s3.head_object(bucket: bucket, key: path)
  true 
rescue
  false
end

options = {}
optparse = OptionParser.new do |parser|
  parser.banner = "Usage: create_iiif_s3.rb -t tmp_dir -s source_bucket -d dest_bucket -c collection_identifer -m csv_metadata_file -i image_folder_path -b metadata_base_path -r dest_root_folder"

  # /usr/local/iiif/tmp/tmp.Nvs5NF9cpD
  # short option, long option, description of the option
  parser.on("-t", "--tmp_dir Name", "Temp dir") do |tmp_dir|
    options[:tmp_dir] = tmp_dir
  end
  parser.on("-s", "--source_bucket Name", "AWS Source Bucket") do |source_bucket|
    options[:source_bucket] = source_bucket
  end
  parser.on("-d", "--dest_bucket Name", "AWS Destination Bucket") do |dest_bucket|
    options[:dest_bucket] = dest_bucket
  end
  parser.on("-c", "--collection_identifier ID", "Parent collection identifier") do |collection_identifier|
    options[:collection_identifier] = collection_identifier
  end
  parser.on("-p", "--metadata_path Path", "CSV path") do |metadata_path|
    options[:metadata_path] = metadata_path
  end
  parser.on("-m", "--metadata_file File", "Metadata CSV file") do |metadata_file|
    options[:metadata_file] = metadata_file
  end
  parser.on("-i", "--image_folder Path", "Path to image folder") do |img_folder|
    options[:image_folder] = img_folder
  end
  parser.on("-b", "--base_path Path", "Base path of metadata file") do |base_path|
    options[:base_url] = base_path
  end
  parser.on("-r", "--dest_root_folder Path", "Path to root folder") do |dest_root_folder|
    options[:dest_root_folder] = dest_root_folder
  end
  parser.on_tail("-h", "--help", "Prints this help") do
    puts parser
    exit
  end
end.parse!

tmp_tmp = "#{options[:tmp_dir]}/tmp"

FileUtils.mkdir_p(options[:tmp_dir]) unless !options[:tmp_dir].nil? && Dir.exists?(options[:tmp_dir])
# s3 upload is handled in the bash calling script after tiling completes
options[:upload_to_s3] = false


credentials = Aws::AssumeRoleCredentials.new(
  role_arn: "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  role_session_name: Time.now.to_s.gsub(" ", "_")
)
s3_client = Aws::S3::Client.new(
  region: "us-east-1",
  credentials: credentials
)
s3_resource = Aws::S3::Resource.new(client: s3_client)

begin
  csv_key = options[:metadata_path] + "/" + options[:metadata_file]
  csv_path = options[:tmp_dir] + "/" + options[:collection_identifier]
  FileUtils.mkdir_p(csv_path) unless !csv_path.nil? && Dir.exists?(csv_path)
  @csv_url = csv_path + "/" + options[:metadata_file]
  File.open(@csv_url, 'wb') do |csv_file|
    reap = s3_client.get_object({ bucket: options[:source_bucket], key: csv_key }, target: csv_file)
  end
rescue StandardError => e
  puts "An error occurred processing metadata file #{@csv_url}: #{e.message}"
end

# collection pattern, e.g., Ms1990_025, is legacy and no longer required
collection_identifier = options[:collection_identifier]
unless image_folder_path = options[:image_folder]
  puts "Please provide path to image folder."
  puts "Try './create_iiif_s3.rb -h'"
  exit
else
  begin
    @input_folder = image_folder_path.slice(image_folder_path.index("#{collection_identifier}")..-1)     
  rescue StandardError => e
    puts "An error occurred processing image folder at #{image_folder_path}: #{e.message}"
  end
end


# Setup Temporary stores
@data = []
# Set up configuration variables
opts = {}
unless opts[:base_url] = options[:base_url]
  puts "Please provide base path for manifest file."
  puts "Try './create_iiif_s3.rb -h'"
  exit
end
opts[:image_directory_name] = "tiles"
opts[:output_dir] = "tmp"
opts[:variants] = { "reference" => 600, "access" => 1200 }
# get the option if upload to S3, absence is false, presence is true
opts[:upload_to_s3] = false
opts[:image_types] = @supported_img_types
opts[:document_file_types] = [".pdf"]
# prefix uses dest_root_folder
unless options[:dest_root_folder]
  puts "Please provide path to root folder"
  puts "Try './create_iiif_s3.rb -h'"
  exit
else
  opts[:prefix] = "#{options[:dest_root_folder]}/#{@input_folder.split('/')[0..-3].join('/')}"
end

iiif = IiifS3::Builder.new(opts)
@config = iiif.config

# sort image files in the image folder
begin
  all_access_image_files = get_s3_filelist_for_item(s3_client, options)
  @image_files = all_access_image_files.select{ |f| is_image_file?(f) }.sort
rescue StandardError => e
  puts "An error occurred processing image folder at #{image_folder_path}: #{e.message}"
end


path = "#{@config.output_dir}#{@config.prefix}/"
create_directories(path)

# generate a path on disk for "output_dir/prefix/image_dir"
img_dir = "#{path}#{@config.image_directory_name}/".split("/")[0...-1].join("/")
create_directories(img_dir)

id = @input_folder.split("/")[-2]
@image_files.each_with_index do |image_file, idx|
  tmp_path = options[:tmp_dir] + "/" + File.basename(image_file)
  File.open(tmp_path, 'wb') do |file|
    reap = s3_client.get_object({ bucket: options[:source_bucket], key: image_file }, target: file)
  end

  add_image(tmp_path, id, idx)
  puts "Passing image file #{image_file} to iiif_s3 gem for processing..."
  iiif.load(@data)
  iiif.process_data
  tmp_contents = Dir["#{tmp_tmp}/**/*"]
  for file in tmp_contents
    if File.file?(file)
      if file.end_with?("metadata.csv")
        dest_key = csv_key
      else
      dest_key = file.sub tmp_tmp + "/", ""
      end
      begin
        s3_client.put_object({ bucket: options[:dest_bucket], key: dest_key, body: File.open(file) })
      rescue StandardError => e
        puts "An error occurred uploading image file #{file}: #{e.message}"
      end
      if s3_exists?(s3_client, options[:dest_bucket], dest_key)
        FileUtils.rm(file) unless file.nil? || !File.exists?(file)
      else
        puts "Failed to upload #{dest_key} to S3"
      end
    end
  end
end


puts "Processing complete"
puts "Exiting job."
