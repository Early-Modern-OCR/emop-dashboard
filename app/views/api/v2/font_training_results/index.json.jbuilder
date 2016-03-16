json.array! @font_training_results.collect { |font_training_result| font_training_result.to_builder('v2').attributes! }
