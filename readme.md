## Voronoi Polygon Generator written in Lua

![Example Diagram, 50 points and 3 iterations](readme_files/examplediagram.png)

License
---
MIT License

What this is
----
This is free to use Lua implementation of a Voronoi Generator. I wanted to experiment with using voronoi polygons to create a procedurally generated landscape and could not find a lua implementation to use that I liked. I programmed one from scratch which did not use any fast or popular algorithm (it use a geometric algorithm) which resulted in calculation times of up to 15 minutes for a 200 point diagram. This algorithm (Fortune's Algorithm) does that in a matter of seconds.

The intent of this project is to have a simple to use Voronoi generator which allows one to access the polygons and their relationships with other polygons.

How to Use
----
Included in the project are 'tests' which were used when developing the library to ensure the functions were performing as intended. These 'tests' can also be used to learn and understand the functionality available. The tests are also linked below in the functions folder (if they deal with a specific function. There are more tests available in the 'tests' folder)

Library Functions
----
[voronilib:getEdges(...)](tests/voronoilib_getEdges/ "the voronoi:getEdges(...) function")

[voronilib:getNeighbors(...)](tests/voronoilib_getNeighbors/ "the voronoi:getNeighbors(...) function")


Sources / Credits
----

Polygon detection, iteration, structuring by Domagoj Jursic (2013)
https://github.com/interstellarDAVE

Lua translation of Fortune's Algorithm from David Ng (2010)
https://love2d.org/forums/viewtopic.php?f=5&t=4212

Original algorithm from Steve J. Fortune (1987) 
A Sweepline Algorithm for Voronoi Diagrams, Algorithmica 2, 153-174, and its translation to C++ by Matt Brubeck, 
http://www.cs.hmc.edu/~mbrubeck/voronoi.html
