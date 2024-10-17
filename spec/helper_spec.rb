# frozen_string_literal: true

RSpec.describe Aissue::Helper do
  it "methods" do
    methods = [:post_openai, :get_file_contents, :create_issue, :record_issue]
    methods.each do |method|
      expect(Aissue::Helper.private_method_defined?(method)).to be true
    end
  end
end
