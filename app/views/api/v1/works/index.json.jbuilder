json.array! @works.collect { |work| work.to_builder('v1').attributes! }
