# grammar-analyzer-cangjie
## 基本介绍
Implementation of a grammar analyzer using Cangjie language as lab3 in HDU compilers course

在杭州电子科技大学编译原理课程实践中，作为实验三实现的基于仓颉语言的语法分析器

It has realized the functions of eliminating left recursion, extracting left common factors, calculating FIRST sets and FOLLOW sets, determining LL(1) grammars, constructing predictive parsing tables, and implementing a syntax analyzer.

实现了消除左递归、提取左公因子、求FIRST集和FOLLOW集、LL(1)文法判定、构造预测分析表和实现语法分析器的功能

## 样例运行流程
```
>cjpm run
S -> S+T | T
T -> T*F | F
F -> (S) | id

Original grammar:
S -> S+T | T 
T -> T*F | F 
F -> (S) | id 
After eliminating left recursion:
F -> (S) | id 
S -> TS' 
T -> (S)T' | idT' 
S' -> +TS' | ε 
T' -> *FT' | ε 
After eliminating left factor:
F -> (S) | id 
S -> TS' 
T -> (S)T' | idT' 
S' -> +TS' | ε 
T' -> *FT' | ε 
F -> (S) | id 
S -> TS' 
T -> (S)T' | idT' 
S' -> +TS' | ε 
T' -> *FT' | ε 
FIRST(F) = [(, i]
FIRST(S) = [(, i]
FIRST(T) = [(, i]
FIRST(S') = [+, ε]
FIRST(T') = [*, ε]
FOLLOW(F) = [*, +, $, )]
FOLLOW(S) = [$, )]
FOLLOW(T) = [+, $, )]
FOLLOW(S') = [$, )]
FOLLOW(T') = [+, $, )]
check LL(1): true
M[F, (] = F -> (S)
M[F, i] = F -> id
M[S, (] = S -> TS'
M[S, i] = S -> TS'
M[T, (] = T -> (S)T'
M[T, i] = T -> idT'
M[S', +] = S' -> +TS'
M[S', $] = S' -> ε
M[S', )] = S' -> ε
M[T', *] = T' -> *FT'
M[T', +] = T' -> ε
M[T', $] = T' -> ε
M[T', )] = T' -> ε
Input a string to analyze: id+id*id
Step 1:
Stack: S$
Input: id+id*id$
Action:

Step 2:
Step 2:
Stack: TS'$
Input: id+id*id$
Action: S -> TS'

Step 3:
Step 3:
Stack: idT'S'$
Input: id+id*id$
Action: T -> idT'

Step 4:
Step 4:
Stack: dT'S'$
Input: d+id*id$
Action: Match i

Step 5:
Step 5:
Stack: T'S'$
Input: +id*id$
Action: Match d

Step 6:
Step 6:
Stack: S'$
Input: +id*id$
Action: T' -> ε

Step 7:
Step 7:
Stack: +TS'$
Input: +id*id$
Action: S' -> +TS'

Step 8:
Step 8:
Stack: TS'$
Input: id*id$
Action: Match +

Step 9:
Step 9:
Stack: idT'S'$
Input: id*id$
Action: T -> idT'

Step 10:
Step 10:
Stack: dT'S'$
Input: d*id$
Action: Match i

Step 11:
Step 11:
Stack: T'S'$
Input: *id$
Action: Match d

Step 12:
Step 12:
Stack: *FT'S'$
Input: *id$
Action: T' -> *FT'

Step 13:
Step 13:
Stack: FT'S'$
Input: id$
Action: Match *

Step 14:
Step 14:
Stack: idT'S'$
Input: id$
Action: F -> id

Step 15:
Step 15:
Stack: dT'S'$
Input: d$
Action: Match i

Step 16:
Step 16:
Stack: T'S'$
Input: $
Action: Match d

Step 17:
Step 17:
Stack: S'$
Input: $
Action: T' -> ε

Step 18:
Step 18:
Stack: $
Input: $
Action: S' -> ε

Step 19:
Accept!

cjpm run finished
```