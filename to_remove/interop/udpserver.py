#!/usr/bin/python
# UDP server example
import socket, IN
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind(("", 5000))
#server_socket.setsockopt(socket.SOL_SOCKET,IN.SO_BINDTODEVICE,'ath1' + '\0')
server_socket.setsockopt(socket.SOL_SOCKET,IN.SO_BINDTODEVICE,'wlan0' + '\0')
#server_socket.setsockopt(socket.SOL_SOCKET,IN.SO_BINDTODEVICE,'wlan1' + '\0')

print"UDPServer Waiting for client on port 5000"
numLines = 0

f = open('./data/rxdata','w')

stop = 0;
while stop < 200000:
  	data, address = server_socket.recvfrom(256)
#    print "( " ,address[0], " " , address[1] , " ) said : ", data
	numLines = numLines + 1
	print numLines, '\n'
	print data
	#if data.isspace() != True:
	f.write(data)
	stop = stop + 1

f.close()
