require 'honeydew/authz/afid'
require 'honeydew/authz/bearer'

module Honeydew

  module Authz

    def warden
      env['warden']
    end
  
  end

end
