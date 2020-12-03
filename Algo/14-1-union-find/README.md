## Union-Find (UF) Data-Structure

Based on work from Robert Sedgewick and Kevin Wayne [Algorithms, 4th Edition](https://algs4.cs.princeton.edu/15uf), Section 1.5 (java implementation).

This implementation in Julia Language represents a <em>union–find data structure</em> (also known as the <em>disjoint-sets data type</em>).
It supports the <em>union</em> and <em>find</em> operations, along with a <em>count</em> operation that returns the total number of sets (or components).

The union–find data structure models a collection of sets containing <em>n</em> elements, with each element in exactly one set.
The elements are named 1 through <em>n</em>.
Initially, there are <em>n</em> sets, with each element in its own set. The <em>canonical element</em> of a set (aka the <em>root</em>, <em>identifier</em>, <em>leader</em>, or <em>set representative</em>) is one distinguished element in the set.

Summary of the operations supported by UF:
 - <em>find</em>(<em>p</em>) returns the canonical element of the set containing <em>p</em>. The <em>find</em> operation returns the same value for two elements if and only if they are in the same set.
 - <em>union</em>(<em>p</em>, <em>q</em>) merges the set containing element <em>p</em> with the set containing element <em>q</em>. That is, if <em>p</em> and <em>q</em> are in different sets, replace these two sets with a new set that is the union of the two.
 - <em>count</em>() returns the number of sets (or components)

The root of a set can change only when the set itself changes during a call to <em>union</em>, it cannot change during a call to either <em>find</em> or <em>count</em>.

This implementation uses <em>weighted quick union by size</em> (without path compression).
- Constructor takes &Theta;(<em>n</em>), where <em>n</em> is the number of elements.
- <em>union</em> and <em>find</em> operations  take &Theta;(ln <em>n</em>) time in the worst case.
- <em>count</em> operation takes &Theta;(1) time.
