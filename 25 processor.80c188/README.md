# Duodyne 80c188 Card
80c188 processor board (hardware and software) for the Duodyne computer system.

Based on the Retrobew Computer SBC-188 board by John Coffman


Bugs 
   To get RAM access -- A21 needs to be high, and it is not. Also A20 should not be left floating.   
        Connect P2 Pin 26 to U17 Pin 18.
        Connect P2 Pin 28 to U17 Pin 16.
        Connect RN1 Pin 3 to U17 Pin 2.
        Connect RN1 Pin 5 to U17 Pin 4.
        Cut Trace between U17 Pin 1 and Pin 19 (bottom of board)
        Connect U17 Pin 1 U6 Pin 19