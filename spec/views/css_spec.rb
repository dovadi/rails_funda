require File.dirname(__FILE__) + '/../spec_helper'

describe "CSS validator" do
  # Where our css is located
  CSS_PATH = RAILS_ROOT + '/public/stylesheets'
  
  # CSS we don't want to process
  EXCEPTIONS = ["#{CSS_PATH}/invalid.css"]
  
  (Dir::glob("#{CSS_PATH}/**/*.css") - EXCEPTIONS).each do |file_name|
    # Create a test name by converting "/.../stylesheets/foo.css" to "foo"
    test_name = file_name.scan(/^.*\/public\/stylesheets\/(.*)\.css/)[0][0].gsub("/", "_")
    self.class_eval "
      it \"checks #{test_name} css\" do
        file_contents = File.open(\"#{file_name}\",'rb').read
        file_contents.should be_valid_css(\"#{test_name}\")
      end"
  end
end