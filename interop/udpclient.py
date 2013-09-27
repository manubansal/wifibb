#!/usr/bin/python
# UDP client example - sendall
import socket, sys, time, IN
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#client_socket.setsockopt(socket.SOL_SOCKET,IN.SO_BINDTODEVICE,'wlan0' + '\0')
#host = "192.168.1.1" #sys.argv[1]  # server address
host = "192.168.1.2" #sys.argv[1]  # server address
#host = "10.33.3.26" #sys.argv[1]  # server address
#host = "192.168.1.1" #sys.argv[1]  # server address
#host = "10.33.3.26" #sys.argv[1]  # server address
#host = "171.64.95.195" #sys.argv[1]  # server address
client_socket.connect((host, 5000))

fixeddata_len = 100	#bytes
fixeddata = ""
#for i in range(1,48):
while (len(fixeddata) < fixeddata_len):
	#fixeddata = fixeddata + repr(i) + " Vighnesh Rege sending data"
	fixeddata = fixeddata + "abcd"
print fixeddata
print len(fixeddata)
#exit

stop = 0
i = 0
while i != 300000:

	i = i + 1
	data = repr(i) + fixeddata

	client_socket.sendall(data)

	if data == '':
		break

client_socket.close()
