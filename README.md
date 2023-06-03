# FPGA_Network
This project is a circuit switched FPGA network. 
### The Files you will need are Node.vhd, UART_Tx.vhd,UART_Rx.vhd,router.vhd
## requests
each packet is 8 bits supporting 3 types of requests :
### 1 - RESERVE PATH
| request type | Target X cooridante of the reciever | Target Y coordinate of the reciever |
| :---:   | :---: | :---: |
| 2b | 3b | 3b |


a two way path is reserved from the sender to the reciever, in order for the reciever to send ACK packet
### 2 - ACK :
after the reserve packet reaches the reciever an ACK is sent to the sender then the path from the reciever to the sender is released
### 3- RELEASE PATH:
after the sender is done , this packet is sent to release the resouces so that this path can be used by other nodes
## router logic
#### we have 5 Tx,Rx pairs - 4 real pairs will be connected to UART blocks and one virtual pair connected to the FPGA itself (it is referred to by self in the code)
##### 1- we loop on the input Rxs and the virtual port(to check if the board wants to send any packets) --- (this is time multplexing) for each input (if available)
##### 2- for each Rx a 4 cycle FSM starts
###### Read -> assign ports -> write -> release (if request= ACK or request = RELEASE)


