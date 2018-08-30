# Copyright 2011-2018, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'rails_helper'

describe ApplicationController do
  controller do
    def index

    end

    def create
      render nothing: true
    end

    def show
      raise Ldp::Gone
    end
  end

  context "normal auth" do
    it "should check for authenticity token" do
      expect(controller).to receive(:verify_authenticity_token)
      post :create
    end
  end
  context "ingest API" do
    before do
      ApiToken.create token: 'secret_token', username: 'archivist1@example.com', email: 'archivist1@example.com'
    end
    it "should not check for authenticity token for API requests" do
      request.headers['Avalon-Api-Key'] = 'secret_token'
      expect(controller).not_to receive(:verify_authenticity_token)
      post :create
    end
  end

  describe '#get_user_collections' do
    let(:collection1) { FactoryGirl.create(:collection) }
    let(:collection2) { FactoryGirl.create(:collection) }

    it 'returns all collections for an administrator' do
      login_as :administrator
      expect(controller.get_user_collections).to include(collection1)
      expect(controller.get_user_collections).to include(collection2)
    end
    it 'returns only relevant collections for a manager' do
      login_user collection1.managers.first
      expect(controller.get_user_collections).to include(collection1)
      expect(controller.get_user_collections).not_to include(collection2)
    end
    it 'returns no collections for an end-user' do
      login_as :user
      expect(controller.get_user_collections).to be_empty
    end
    it 'returns no collections to end-user, even when passing user param' do
      login_as :user
      expect(controller.get_user_collections collection1.managers.first).to be_empty
    end
    it 'returns requested user\'s collections for an administrator' do
      login_as :administrator
      expect(controller.get_user_collections collection1.managers.first).to include(collection1)
      expect(controller.get_user_collections collection1.managers.first).not_to include(collection2)
    end
  end

  describe "exceptions handling" do
    it "renders deleted_pid template" do
      get :show, id: 'deleted-id'
      expect(response).to render_template("errors/deleted_pid")
    end
  end

  describe "rewrite_v4_ids" do
    it 'skips when id is not a Fedora 3 pid' do
      get :show, id: 'abc1234'
      expect(response).not_to have_http_status(304)
    end

    it 'skips post requests' do
      post :create, id: 'avalon:1234'
      expect(response).not_to have_http_status(304)
    end
  end

  describe "layout" do
    render_views

    it 'renders avalon layout' do
      get :show, id: 'abc1234'
      expect(response).to render_template("layouts/avalon")
    end

    it 'renders google analytics partial' do
      get :show, id: 'abc1234'
      expect(response).to render_template("modules/_google_analytics")
    end
  end
end
