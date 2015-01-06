json.array! @pages.collect { |page| page.to_builder('v1').attributes! }
