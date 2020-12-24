# Programming Problem 19: Traveling Salesman Problem [TSP]

  Using DP, Bellman-Held-Karp Algorithm


## Work

 - In this assignment you will implement one or more algorithms for the traveling salesman problem, such as the dynamic programming algorithm covered in the video lectures.  Here is a data file describing a TSP instance.  
   [This file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/19-1-tsp/testfiles/tsp.txt) describes an instance of a TSP. 

The first line indicates the number of cities.  Each city is a point in the plane, and each subsequent line indicates the x- and y-coordinates of a single city.  

The distance between two cities is defined as the Euclidean distance, that is, two cities at locations (x,y) and (z,w) have distance  
    √((x - z)² + (y - w)²)​ between them.  

In the box below, type in the minimum cost of a traveling salesman tour for this instance, rounded down to the nearest integer.

OPTIONAL: If you want bigger data sets to play with, check out the TSP instances from around the world [here](http://www.tsp.gatech.edu/world/countries.html).  The smallest data set (Western Sahara) has 29 cities, and most of the data sets are much bigger than that.  What's the largest of these data sets that you're able to solve --- using dynamic programming or, if you like, a completely different method?

HINT: You might experiment with ways to reduce the data set size.  For example, trying plotting the points.  Can you infer any structure of the optimal solution?  Can you use that structure to speed up your algorithm?


ref. Coursera/Stanford Algorithms [Shortest Paths Revisited, NP-Complete Problems and What To Do About Them](https://www.coursera.org/learn/algorithms-npcomplete/home/)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA

<hr />
<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
