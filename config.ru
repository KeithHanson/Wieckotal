require 'rubygems'
require 'rack'
require 'wieckotal'
require 'rack-flash'

use Rack::Session::Cookie, :expire_after => 6.months.to_i

use Rack::Flash, :accessorize => [:notice, :error]

run Wieckotal.new
