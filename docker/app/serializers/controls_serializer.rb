class ControlsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id,
             :guid,
             :control_id,
             :title,
             :tag_map,
             :impact,
             :status,
             :resources_failed,
             :resources_total
end
