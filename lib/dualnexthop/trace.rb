module Dualnexthop
  class trace

    def randomport
      rand(30535) + 35000
    end

    # This class performs a traceroute and returns the maximum latency detected and number of timeouts detected.
    #
    # @option args [Integer] :firsthop The initial hop of where to begin the trace..
    # @option args [Integer] :lasthop The last hop to consider in the trace.
    # @option args [String] :sourceAddress The source address to operate this trace from.
    # @option args [Array] :targets An array containing a list of targets to evaluate.
    #
    # @return [Integer] :maxLatency The maximum latency detected throughout the test.
    # @return [Integer] :timeouts The number of timeouts that occured with this test.

    def self.execute( args = {})
      require 'timeout'
      require 'socket'
      require 'time'     
 
      localPort = randomport
      remotePort = randomport
      localAddress = args[:sourceAddress] 
      topLatency = 0
      timeOutCount = 0

    args[:targets].each do | target |

      packetTTL = args[:firsthop]

      udpSocket    = UDPSocket::new
      begin
        udpSocket.bind( localAddress, port )
      rescue 
        port = self.randomport
        retry
      end 
 
       icmpSocket = Socket.open( Socket::PF_INET, Socket::SOCK_RAW, Socket::IPPROTO_ICMP )
       icmpSocketAddr = Socket.pack_sockaddr_in( localPort, localAddress )
       icmpSocket.bind( icmpSocketAddr )
        begin
          udpSocket.connect( target, remotePort )
        rescue SocketError => err_msg
          raise "Failed to connect (#{err_msg})." 
        end
    
        until packetTTL == args[:lasthop]

          udpSocket.setsockopt( 0, Socket::IP_TTL, packetTTL )
          packetSent = Time.now
          latencyArray = Array.new
          udpSocket.send( "UDP Traceroute to determine path availability.", 0 )
          begin
            Timeout::timeout( 1 ) {
              payload, sender = icmpSocket.recvfrom( 1024 )
              latencyArray << (( Time.now - packetSent ) * 1000 ).floor 
              # 20th and 21th bytes of IP+ICMP datagram carry the ICMP type and code resp.
              type = payload.unpack( '@20C' )[0]
              code = payload.unpack( '@21C' )[0]
              if ( type == 3 and code == 3 )
                break
              end
            }
          rescue Timeout::Error
            timeOutCount += 1
            latencyarray << 0
          end
          packetTTL += 1
        end

        latencyArray.sort! { |x,y| y <=> x } 
        return { maxLatency: latencyArray[1], timeouts: timeOutCount }
     end
    end
  end
end
