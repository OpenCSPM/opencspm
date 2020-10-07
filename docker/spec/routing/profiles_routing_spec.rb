require "rails_helper"

RSpec.describe ProfilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/profiles").to route_to("profiles#index")
    end

    it "routes to #show" do
      expect(get: "/profiles/1").to route_to("profiles#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/profiles").to route_to("profiles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/profiles/1").to route_to("profiles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/profiles/1").to route_to("profiles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/profiles/1").to route_to("profiles#destroy", id: "1")
    end
  end
end
