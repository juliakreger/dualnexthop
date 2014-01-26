require 'time'
require 'dualnexthop/trace'
require 'dualnexthop/interfaces'

module Dualnexthop

  # This is intended TODO
  #
  # @example Standard Usage
  #
  #     dualnexthop.execute source: 'localhost:9200', destination: 'remotehost:9200'
  #
  # @option arguments [Array]<hash> :interfaces This is an array listing the interfaces with to evaluate.  ["eth0" => "priorityNumber"]
  # @option arguments [Array] :targets An array of targets to trace towards. (Default: ["www.google.com","www.amazon.com"])
  # @option arguments [Integer] :firstHop First hop to consider (Default: 2)
  # @option arguments [Integer] :lastHop Last hop to consider (Default: 5)
  # @option arguments [Integer] :maxTimeouts Optional Maximum timeouts before connection is flagged as bad.
  #                                          (Default: ( lasthop - firsthop )
  # @option arguments [Integer] :maxLatency Maximum latency permitted from the upstream hops before connection is flagged as bad
  #                                         in milliseconds. (Default: 100)
  # @option arguments [Integer] :tempPathWeight Optional (Default: 10 which will result in a 10:1 traffic ratio)
  # @option arguments [String] :email Optional If defined, Send an email to the defined address
  # @option arguments [Boolean] :verbose Output status text. 
  # @option arguments [Boolean] :testing This flag is reserved for when this tool is called for testing, prevents command execution.
  # @option arguments [String] :gatewayFile Optional file denoting where to find the information on the gateway. 
  #                                         Based on the file name, appropriate filter will be used. 
  #                                         (Default: "/var/lib/dhcp/dhclient.INTERFACE.leases")
  #

  def self.execute( arguments={} )

    # Setting defaults, sanity checking.
    if arguments[:interfaces].nil?
      raise "Error: Interfaces must be defined"
    end
    if arguments[:targets].nil?
      arguments[:targets] = ["www.google.com","www.amazon.com"]
    end
    if arguments[:firstHop].nil?
      arguments[:firstHop] = 2
    end
    if arguments[:lastHop].nil?
      arguments[:lastHop] = 5
    end
    if arguments[:maxTimeouts].nil?
      arguments[:maxTimeouts] = ( arguments[:lasthop] - arguments[:firsthop] )
    end
    if arguments[:maxLatency].nil?
      arguments[:maxLaency] = 100
    end
    if arguments[:tempPathWeight].nil?
      arguments[:tempPathWeight] = 10
    end
    if arguments[:verbose].nil?
      arguments[:verbose] = false
    end    
    if arguments[:testing].nil?
      arguments[:testing] = false
    end
    if arguments[:gatewayFile].nil?
      arguments[:gatewayFile] = "/var/lib/dhcp/dhclient.INTERFACE.leases"
    end


    # determine interface state   interfaces.status
      # if down to one interface, block taking down any other interfaces.
      # determine gateway, IP address, store in interfaces hash  interfaces.gateway interfaces.address
      # determine if interface gateway is actively utilized  interfaces.active_gateway?  
      # test each gateway for arpability if interface up interfaces.gateway_up?
      # 
#old      # If arp works, if no route exists, add route, proceed as normal
#old      # if arp fails, if route exists, remove route


#call route handler with handle routes
  #route handler checks if arp failed, if loadeded as a active route, it removes it.
  # if arp works, but route is missing, no action necessary, flag for route update to occur
  #abort if <= 1 viable route remains
   #else
    traceroute here!

    #call custom route massager
     # change routes.
     # refesh regardless if we're flagged for an update. I.E. we should be multihomed but we're not.
   
somewhere send an email    

        pathresults = Dualnexthop::Trace.execute arguments
          

  end
end
