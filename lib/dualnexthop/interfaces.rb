module Dualnexthop
  class Interfaces

    # This method should be equilvelent of exucuting `ip link show interfacename`
    #
    # @option args [Hash] :interface Name of the interface to determine the Gateway for.
    #
    # @return [Boolean] Returns a boolean value, true if the interface is up.
 
    def self.status( args = {} )
      result = system('ip', 'link', 'show', args[:interface]).grep(/UP/)
      if result =~ /UP/
        true
      else
        false
      end
    end

    # This method utilizes system utilit arpping in order to test functionality of the upstream gateway.  Fallback is an ICMP ping via net-ping.    
    #
    # @option args [Hash] :interface Name of the interface to determine the Gateway for.
    # @option args [Hash] :sourceAddress Source IP Address
    # @option args [Hash] :gateway IP address of the nexthop/gateway/router.
    #
    # @return [Boolean] Returns a boolean value, true if the gateway appears reachable.

    def self.gateway_up? ( args = {} )
      #Executes arpping, with arguments quiet, interface, count of two, wait of 1, source, and gateway.
      ping = system('arpping', '-q', '-I', args[:interface], '-c', '2', '-w', '1', '-s', args[:sourceAddress], args[:gateway])
      if ping.nil?
        require 'net-ping'
        ping = Net::Ping::ICMP.ping args[:gateway]
        return true if ping == true
      else
        return true if ping == true
      end
      return false
    end

    # This method identifies the gateway.  Presently it utilizes the dhclient leases file to identify the gateway, but this could
    # be easilly extended in order to support static IP address assignments, or different dhcp clients as long as some sort of file
    # can be read and parsed.
    #
    # @option args [Hash] :interface Name of the interface to determine the Gateway for.
    # @option args [Hash] :gatewayFile File name with all caps INTERFACE text to be replaced by :interface to locate the name.
    # 
    # @return [String] A string value with the IP address of the gateway.

    def self.gateway ( args = {} )
      case args[:gatewayFile]
      when /dhclient/
        gatewayFile = args[:gatewayFile].sub('INTERFACE',args[:interface])
        gatewayContents = file.open( gatewayFile, 'r').read.sub(';','').strip.each_line(separator).to_a
        gatewayLine = gatewayContents[-1].strip.split(' ')
        return gatewayLine[3]
      else
        raise "Error: Presently class interfaces, method gateway only supports dhclient"
      end 
    end

    # @option args [Hash] :gateway IP address of the gateway that we want to determine if its used at present..
 
    def self.active_gateway? ( args = {} )
      nexthopfound = system('ip', 'route').grep('nexthop').grep(args[:gateway])
      if nexthopfound.length > 0
        true
      else
        false
      end
    end

    # This chunk of code identifies the IP address when given an interface name
    #
    # @option args [Hash] :interface Name of the interface to determine the IP for.
    #
    # @return [String] Returns a string containing the IP address bound to the interface in question.


    def self.address( args = {} )
      result = system('ifconfig', args[:interface]).grep(/inet /)
      if result.nil?
        raise "Error: unable to obtain address for #{args[:interface]} with message #{$?}"
      elsif result
        case RUBY_PLATFORM
        when /darwin/
          #This case is only here as initial development was on MacOS
          resultarray = result.strip.split(' ')
          return resultarray[2]
        when /linux/
          resultarray = result.sub(':',' ').strip.split(' ')
          return resultarray[3]
        else
          raise "Error: Operating System not supported by interfaces class"
        end
      else
        raise "Error: unable to obtain address for #{args[:interface]}, no data returned."
      end
    end
  end
end
