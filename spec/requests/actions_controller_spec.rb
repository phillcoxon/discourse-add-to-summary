# frozen_string_literal: true
require 'rails_helper'

describe DiscourseAddToSummary::ActionsController do
  before do
    SiteSetting.queue_jobs = false
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/discourse-add-to-summary/list.json"
    expect(response.status).to eq(200)
  end
end
