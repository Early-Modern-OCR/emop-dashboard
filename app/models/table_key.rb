
class TableKey < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :table_keys
end