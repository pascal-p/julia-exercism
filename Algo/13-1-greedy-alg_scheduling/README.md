# Implementing "Scheduling: minimizing the weighted sum of completion times"

  **Programming Problem 13.1:** using a greedy approach


## Work

 - Challenge data set: This [file](https://github.com/pascal-p/julia-exercism/blob/master/Algo/13-1-greedy-alg_scheduling/testfiles/jobs.txt)  

 1. This file describes a set of jobs with positive and integral weights and lengths. It has the format


        [number_of_jobs]
        [job_1_weight] [job_1_length]
        [job_2_weight] [job_2_length]
        ...

*For example, the third line of the file is "74 59", indicating that the second job has weight 74 and length 59.*

You should NOT assume that edge weights or lengths are distinct.

Your task in this problem is to run the greedy algorithm that schedules jobs in decreasing order of the difference (weight - length). Recall from lecture that this algorithm is not always optimal. IMPORTANT: if two jobs have equal difference (weight - length), you should schedule the job with higher weight first. Beware: if you break ties in a different way, you are likely to get the wrong answer. You should report the sum of weighted completion times of the resulting schedule --- a positive integer --- in the box below. *Answer: 69_119_377_652*

  2. For this problem, use the same data set as in the previous problem.  

Your task now is to run the greedy algorithm that schedules jobs (optimally) in decreasing order of the ratio (weight/length). In this algorithm, it does not matter how you break ties. You should report the sum of weighted completion times of the resulting schedule --- a positive integer --- in the box below. *Answer: 67_311_454_237*


ref. Coursera/Stanford Algorithms [Greedy Algorithms, Minimum Spanning Trees, and Dynamic Programming](https://www.coursera.org/learn/algorithms-greedy/home/welcome)

## Version compatibility
This exercise has been tested on Julia versions >=1.0.

## Submitting Incomplete Solutions
#NA  

<p style="font-size:0.25em">Dec. 2020, Corto Inc</p>
