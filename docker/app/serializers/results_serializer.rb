class ResultsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :job_id, :data, :observed_at
end
