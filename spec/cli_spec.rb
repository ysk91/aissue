# frozen_string_literal: true

RSpec.describe Aissue::CLI do
  it "can use start" do
    expect(Aissue::CLI.methods).to include(:start)
  end
end
