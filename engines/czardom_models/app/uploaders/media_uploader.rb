# encoding: utf-8

class MediaUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  
    # For Rails 3.1+ asset pipeline compatibility:
    "http://"+CzardomEvents::Engine.routes.default_url_options[:host]+ActionController::Base.helpers.asset_path("fallback/" + ["default-avatar.png"].compact.join('_'))
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  process :store_dimensions

  
  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end
  version :large do
    process :resize_to_fill => [512, 512]
  end

  version :thumb do
    process :resize_to_fill => [256, 256]
  end
  
  version :small do
    process :resize_to_fill => [128, 128]
  end

  version :tiny do
    process :resize_to_fill => [64, 64]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  private

  def store_dimensions
    if file && model
      img = ::Magick::Image::read(file.file).first
      model.width = img.columns
      model.height = img.rows
    end
  end

end
