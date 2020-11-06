require 'rails_helper'

RSpec.describe Api::SourcesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/sources').to route_to('sources#index')
    end

    it 'routes to #show' do
      expect(get: '/sources/1').to route_to('sources#show', id: '1')
    end

    it 'routes to #create' do
      # expect(post: '/sources').to route_to('sources#create')
      expect(post: '/sources').not_to be_routable
    end

    it 'routes to #update via PUT' do
      expect(put: '/sources/1').to route_to('sources#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/sources/1').to route_to('sources#update', id: '1')
    end

    it 'routes to #destroy' do
      # expect(delete: "/sources/1").to route_to("sources#destroy", id: "1")
      expect(delete: '/sources/1').not_to be_routable
    end
  end
end
