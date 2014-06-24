$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'timecop'
require 'resident'

RSpec.configure do |config|

  config.after(:each) do
    # Preventing the mistake of forgetting to return to present time
    # See http://www.51degrees.net/2010/01/18/global-after-blocks-or-keeping-timcop-happy.html
    Timecop.return
  end

end
