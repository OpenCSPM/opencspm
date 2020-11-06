require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organizations').to route_to('organizations#index')
    end

    it 'routes to #show' do
      expect(get: '/organizations/1').to route_to('organizations#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/organizations').to route_to('organizations#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/organizations/1').to route_to('organizations#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/organizations/1').to route_to('organizations#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1').to route_to('organizations#destroy', id: '1')
    end
  end
end
