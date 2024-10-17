# frozen_string_literal: true

RSpec.describe Aissue::Issue do
  it "can use rescue" do
    expect(Aissue::Issue.methods).to include(:rescue)
  end
end
