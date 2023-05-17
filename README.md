# FPGA_Network
This project is a circuit switched FPGA network.
## requests
each packet is 8 bits supporting 3 types of requests :
### 1 - RESERVE PATH
| 2b           | 3b                                  | 3b                                 
| :---:   | :---: | :---: |
| request type | Target X cooridante of the reciever | Target Y coordinate of the reciever
a two way path is reserved from the sender to the reciever, in order for the reciever to send ACK packet
### 2 - ACK :
after the reserve packet reaches the reciever an ACK is sent to the sender then the path from the reciever to the sender is released
### 3- RELEASE PATH:
after the sender is done , this packet is sent to release the resouces so that this path can be used by other nodes

