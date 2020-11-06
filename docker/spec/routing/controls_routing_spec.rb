require 'rails_helper'

RSpec.describe Api::ControlsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/controls').to route_to('controls#index')
    end

    it 'routes to #show' do
      expect(get: '/controls/1').to route_to('controls#show', id: '1')
    end

    it 'routes to #create' do
      # expect(post: '/controls').to route_to('controls#create')
      expect(post: '/controls').not_to be_routable
    end

    it 'routes to #update via PUT' do
      # expect(put: '/controls/1').to route_to('controls#update', id: '1')
      expect(put: '/controls/1').not_to be_routable
    end

    it 'routes to #update via PATCH' do
      # expect(patch: '/controls/1').to route_to('controls#update', id: '1')
      expect(patch: '/controls/1').not_to be_routable
    end

    it 'routes to #destroy' do
      # expect(delete: '/controls/1').to route_to('controls#destroy', id: '1')
      expect(delete: '/controls/1').not_to be_routable
    end
  end
end
