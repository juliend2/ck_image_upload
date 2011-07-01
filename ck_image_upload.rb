
module Joiedmin::AdminApplications
  class CKImageUpload < Joiedmin::AdminController
    template :layout do
      Joiedmin.admin_layout('ck_image_upload')
    end
    set :views, File.dirname(__FILE__) + "/views"
    set :public, File.dirname(__FILE__) + "/public"
    set :upload_path, '/uploads/images'

    post '/upload' do
      unless params[:upload] &&
             (tmpfile = params[:upload][:tempfile]) &&
             (name = params[:upload][:filename])
        return "No file selected"
      end
      # TODO: check that we have the "image" folder already there before uploading
      directory = "public#{settings.upload_path}"
      path = File.join(directory, name)
      # We're using a "while" because a plain f.write(tmpfile.read) would use 
      # as much RAM as the size of the attachment.
      # Found here : http://www.ruby-forum.com/topic/193036
      while blk = tmpfile.read(65536)
        File.open(path, "a") { |f| f.write(blk) }
      end
      %Q"<script type='text/javascript'>
        var CKEditorFuncNum = #{params[:CKEditorFuncNum]};
        window.parent.CKEDITOR.tools.callFunction( CKEditorFuncNum, '#{settings.upload_path}/#{name}' );
      </script>"
    end
    
    get '/uploaded_images' do
      @images = []
      basedir = "./public#{settings.upload_path}"
      contains = Dir.new(basedir).entries
      rejected = ['.', '..', '.DS_Store'] # ignore these filenames
      @images = contains.reject {|f| rejected.include? f }
      erb :uploaded_images, :layout=>false
    end
  
  end
end
