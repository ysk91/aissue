require_relative 'lib/aissue/issue'

begin
  100 / 0
rescue => e
  Aissue::Issue.rescue(e)
end
