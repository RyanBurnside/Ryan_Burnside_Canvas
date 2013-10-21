Ryan Burnside's Canvas
This is a tool to render simple shapes to the screen.
Some programming languages can't render graphics, this lets them do that.
Eventually I want the Lisp program to receive piped data.
It can only load static shape files for now... (Python version worked easier)

The following is a command list:
The first letter tells what command to use.
Additional parameters are separated by a space.
No trailing spaces please, also one command per line in the file.

All commands occupy a single line!
All color triplets range from 0 to 255
State setting commands are uppercase, drawing are lowercase
example
l 12 12 33 34
Draws a line from (12, 12) to (33, 34)

Set pen color (red green blue)
P

Set brush color (red green blue)
B

Use filled brush (0 for false 1 for true)
U

Set pen width (number)
W

Set canvas color (red green blue)
C

Draw line (x1 y1 x2 y2)
l

Draw rectangle (x1 y1 x2 y2)
r

Draw triangle (x1 y1 x2 y2 x3 y3)
t

Draw polygon (x1 y1 x2 y2 x3 y3 ...)
p - create-polygon

Draw oval (x1 y1 x2 y2)
o

You will need to obtain and compile LTK before you can use it to build this.
http://www.peter-herth.de/ltk/

Documentation is a bit thin on this project.
