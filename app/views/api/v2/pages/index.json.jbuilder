json.array! @pages.collect { |page| page.to_builder('v2').attributes! }
