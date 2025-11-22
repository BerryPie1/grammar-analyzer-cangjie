package lab3

import std.collection.*
import std.sort.*

class Grammar{
    // 文法以哈希表形式存储
    // 键为产生式头，值为产生式体的列表
    // 每个产生式体又是符号的列表
    let heads: ArrayList<String>
    let gram: HashMap<String, ArrayList<ArrayList<String>>>
    let firstSet: HashMap<String, HashSet<String>>
    let followSet: HashMap<String, HashSet<String>>
    let parseTable: HashMap<String, HashMap<String, ArrayList<String>>>
    var computedFirstAndFollow: Bool
    init(strs: ArrayList<String>) {
        computedFirstAndFollow = false
        gram = HashMap<String, ArrayList<ArrayList<String>>>()
        heads = ArrayList<String>()
        firstSet = HashMap<String, HashSet<String>>()
        followSet = HashMap<String, HashSet<String>>()
        parseTable = HashMap<String, HashMap<String, ArrayList<String>>>()
        for(str in strs) {
            // 把产生式分成头和若干个体
            let (head, parts) = StrToList.part(str)
            if(!gram.contains(head)) {
                gram[head] = ArrayList<ArrayList<String>>()
                heads.add(head)
            }
            gram[head].add(all: parts)
        }
    }

    func print() {
        for(head in heads) {
            let prods = gram[head]
            // 标记是否需要打印“|”
            var first = true
            print(head + " -> ")
            for(prod in prods) {
                if(!first){
                    print("| ")
                }
                for(sym in prod) {
                    print(sym)
                }
                first = false
                print(" ")
            }
            println("")
        }
        if(computedFirstAndFollow) {
            for(head in heads) {
                println("FIRST(${head}) = ${firstSet[head]}")
            }
            for(head in heads) {
                println("FOLLOW(${head}) = ${followSet[head]}")
            }
        }
    }

    // 消除直接左递归
    func eliminateDirectLeftRecursion(head: String): Unit {
        var haveDirectLeftRecursion = false
        for(prod in gram[head]) {
            if(prod[0] == head) {
                haveDirectLeftRecursion = true
                break
            }
        }
        // 不存在直接左递归
        if(!haveDirectLeftRecursion) {
            return
        }
        let newHead = head + "'"
        let newProdsOldHead = ArrayList<ArrayList<String>>()
        let newProdsNewHead = ArrayList<ArrayList<String>>()
        for(prod in gram[head]) {
            if(prod[0] == head) {
                // 形如 A -> Aα 的产生式，改为 A' -> αA'
                let newProd = prod[1..].clone()
                newProd.add(newHead)
                newProdsNewHead.add(newProd)
            }
            else {
                // 形如 A -> β 的产生式，改为 A -> βA'
                let newProd = prod.clone()
                newProd.add(newHead)
                newProdsOldHead.add(newProd)
            }
        }
        // A' -> ε
        newProdsNewHead.add(ArrayList<String>([String(r"ε")]))
        heads.add(newHead)
        gram[head] = newProdsOldHead
        gram[newHead] = newProdsNewHead
    }

    // 消除左递归
    func eliminateLeftRecursion(): Unit {
        sort(heads)
        for(i in 0..heads.size) {
            let head_i = heads[i]
            let newProds = ArrayList<ArrayList<String>>()
            // 枚举产生式
            for(prod in gram[head_i]) {
                var find = false
                for(j in 0..i) {
                    let head_j = heads[j]
                    // 找到形如 A_i -> A_j γ (j < i) 的产生式
                    if(prod[0] == head_j) {
                        find = true
                        // 枚举 A_j 的产生式 A_j -> δ
                        for(prod_j in gram[head_j]) {
                            // 拼接为新产生式 A_i -> δ γ
                            let newProd = prod_j.clone()
                            newProd.add(all: prod[1..])
                            newProds.add(newProd)
                        }
                    }
                } 
                // 没有找到形如 A_i -> A_j γ (j < i) 的产生式
                // 则保留原产生式
                if(!find) {
                    newProds.add(prod)
                }
            }
            gram[head_i] = newProds
            eliminateDirectLeftRecursion(head_i)
        }
    }

    // 判断某个产生式头是否有ε产生式
    func haveEpsilonProduction(head: String): Bool {
        for(prod in gram[head]) {
            if(prod.size == 1 && prod[0] == String(r"ε")) {
                return true
            }
        }
        return false
    }

    // 计算产生式头（非终结符）的FIRST集
    func computeFirstSet(head: String): HashSet<String> {
        let result = HashSet<String>()
        for(prod in gram[head]) {
            result.add(all: computeFirstSet(prod))
        }
        firstSet[head] = HashSet<String>(result)
        return HashSet<String>(result)
    }

    // 计算产生式体的FIRST集
    func computeFirstSet(body: ArrayList<String>): HashSet<String> {
        // 如果是ε产生式
        if(body[0] == String(r"ε")) {
            return HashSet<String>([String(r"ε")])
        }
        let result = HashSet<String>()
        var flag = false
        for(sym in body) {
            // 当前符号是非终结符
            if(heads.contains(sym)) {
                let tempFirstSet = computeFirstSet(sym)
                for(sym in tempFirstSet) {
                    if(sym != "ε") {
                        result.add(sym)
                    }
                }
                if(!haveEpsilonProduction(sym)) {
                    flag = true
                    break
                }
            }
            // 当前符号是终结符
            else{
                result.add(sym)
                flag = true
                break
            }
        }
        if(!flag) {
            result.add(String(r"ε"))
        }
        return result
    }

    // false: 没有左公因子 true: 有左公因子 
    func eliminateLongestLeftFactor(head: String): Bool {
        let prods = gram[head]
        let longestLeftFactor = ArrayList<String>()
        for(i in 0..prods.size) {
            // 两两枚举产生式对
            for(j in i+1..prods.size) {
                let prod_i = prods[i]
                let prod_j = prods[j]
                var k = 0
                // 找出最长公共前缀
                while(k < prod_i.size && k < prod_j.size && prod_i[k] == prod_j[k]) {
                    k += 1
                }
                if(k > longestLeftFactor.size) {
                    longestLeftFactor.clear()
                    longestLeftFactor.add(all: prod_i[0..k])
                }
            }
        }
        // 找不到左公因子（公共前缀），无需处理
        if(longestLeftFactor.isEmpty()) {
            return false
        }
        // A的产生式形如A->αβ1 | αβ2 | ... | γ1 | γ2 ...
        // 生成新的产生式头
        var newHead = head + "'"
        while(heads.contains(newHead)) {
            newHead += "'"
        }
        heads.add(newHead)
        let newProdsNewHead = ArrayList<ArrayList<String>>()
        let newProdsOldHead = ArrayList<ArrayList<String>>()
        for(prod in prods) {
            // 判断产生式是否以最长左公因子开头
            if(prod.size >= longestLeftFactor.size) {
                var haveTheLeftFactor = true
                for(k in 0..longestLeftFactor.size) {
                    if(prod[k] != longestLeftFactor[k]) {
                        haveTheLeftFactor = false
                        break
                    }
                }
                // 以最长左公因子开头的产生式进行改写
                if(haveTheLeftFactor) {
                    // 形如 A -> α β 的产生式，改为 A' -> β 和 A -> α A'
                    // 提取β
                    let newProd1 = ArrayList<String>(prod[longestLeftFactor.size..])
                    // 若β为空，则改为 A' -> ε
                    if(newProd1.isEmpty()) {
                        newProd1.add(String(r"ε"))
                    }
                    newProdsNewHead.add(newProd1)
                }
                else {
                    // 不以最长左公因子开头的产生式保留
                    newProdsOldHead.add(prod)
                }
            }
            else {
                // 不以最长左公因子开头的产生式保留
                newProdsOldHead.add(prod)
            }
        }
        let newProd = longestLeftFactor.clone()
        newProd.add(newHead)
        newProdsOldHead.add(newProd)
        gram[head] = newProdsOldHead
        gram[newHead] = newProdsNewHead
        return true
    }

    // 提取左公因子
    func eliminateLeftFactor() {
        for(i in 0..heads.size) {
            let head = heads[i]
            while(true) {
                if(!eliminateLongestLeftFactor(head)) {
                    break
                }
            }
        }
    }

    func computeFirstSet() {
        for(head in heads) {
            computeFirstSet(head)
        }
    }

    func computeFollowSet() {
        // 初始化FOLLOW集
        for(head in heads) {
            followSet[head] = HashSet<String>()
        }
        followSet["S"].add("$")
        var changed: Bool
        do {
            changed = false
            for(A in heads) {
                for(prod in gram[A]) {
                    for(j in 0..prod.size) {
                        let B = prod[j]
                        if(!heads.contains(B)) {
                            continue
                        }
                        let beforeSize = followSet[B].size
                        // A -> α B β
                        if(j < prod.size - 1) {
                            let firstSetBeta = computeFirstSet(prod[j+1..])
                            // 将 FIRST(β) \ {ε} 加入 FOLLOW(B)
                            for(sym in firstSetBeta) {
                                if(sym != "ε") {
                                    followSet[B].add(sym)
                                }
                            }
                            // A -> α B β 且 FIRST(β) 包含 ε，则将 FOLLOW(A) 加入 FOLLOW(B)
                            if(firstSetBeta.contains("ε")) {
                                for(sym in followSet[A]) {
                                    followSet[B].add(sym)
                                }
                            }
                        }
                        // A -> α B，将 FOLLOW(A) 加入 FOLLOW(B)
                        else{
                            for(sym in followSet[A]) {
                                followSet[B].add(sym)
                            }
                        }
                        if(followSet[B].size > beforeSize) {
                            changed = true
                        }
                    }
                }
            }
        } while(changed)
    }

    // 检查交集是否为空
    func intersectionEmpty(set1: HashSet<String>, set2: HashSet<String>): Bool {
        for(sym in set1) {
            if(set2.contains(sym)) {
                return false
            }
        }
        return true
    } 

    // 检查文法是否为LL(1)
    func checkLL1(): Bool {
        for(head in heads) {
            for(i in 0..gram[head].size) {
                for(j in i+1..gram[head].size) {
                    // A -> α | β
                    let alpha = gram[head][i]
                    let beta = gram[head][j]
                    let firstSetAlpha = computeFirstSet(alpha)
                    let firstSetBeta = computeFirstSet(beta)
                    // 检查 FIRST(α) ∩ FIRST(β) 是否为空
                    if(!intersectionEmpty(firstSetAlpha, firstSetBeta)) {
                        return false
                    }
                    // 检查若 ε ∈ FIRST(α)，则 FIRST(β) ∩ FOLLOW(A) 是否为空
                    if(firstSetAlpha.contains("ε")) {
                        if(!intersectionEmpty(followSet[head], firstSetBeta)) {
                            return false
                        }
                    }
                    // 检查若 ε ∈ FIRST(β)，则 FIRST(α) ∩ FOLLOW(A) 是否为空
                    if(firstSetBeta.contains("ε")) {
                        if(!intersectionEmpty(followSet[head], firstSetAlpha)) {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }

    // 构造预测分析表
    func computeParseTable() {
        for(head in heads) {
            parseTable[head] = HashMap<String, ArrayList<String>>()
            for(prod in gram[head]) {
                let firstSetProd = computeFirstSet(prod)
                for(a in firstSetProd) {
                    // 对于产生式 A -> α，若 a ∈ FIRST(α)，则 M[A, a] = α
                    if(a != "ε") {
                        print("M[${head}, ${a}] = ${head} -> ")
                        parseTable[head][a] = prod
                        for(sym in prod) {
                            print(sym)
                        }
                        println("")
                    }
                    else {
                        for(b in followSet[head]) {
                            // 对于产生式 A -> α，若 ε ∈ FIRST(α)，则对于每个 b ∈ FOLLOW(A)，M[A, b] = α
                            print("M[${head}, ${b}] = ${head} -> ")
                            parseTable[head][b] = prod
                            for(sym in prod) {
                                print(sym)
                            }
                            println("")
                        }
                    }
                }
            }
        }
    }

    func showStep(stack: ArrayList<String>, inputStrs: ArrayList<String>, action: String, countStep: Int64) {
        println("Step ${countStep}:")
        print("Stack: ")
        for(i in stack.size-1..=0:-1) {
            print(stack[i])
        }
        println("")
        print("Input: ")
        for(sym in inputStrs) {
            print(sym)
        }
        println("")
        println("Action: " + action)
        println("")
    }

    // 使用预测分析表进行语法分析
    func analyze(strs: ArrayList<String>) {
        let stack = ArrayList<String>(["$", "S"])
        var countStep = 0
        countStep += 1
        showStep(stack, strs, "", countStep)
        while(true) {
            countStep += 1
            println("Step ${countStep}:")
            let r = strs[0]
            let X = stack[stack.size - 1]
            // 如果X等同于输入串的第一个符号
            if(!heads.contains(X)) {
                if(X == r) {
                    if(X == "$") {
                        println("Accept!")
                        return
                    }
                    stack.remove(at: stack.size - 1)
                    strs.remove(at: 0)
                    showStep(stack, strs, "Match ${X}", countStep)
                }
                else {
                    println("Error: terminal symbol ${X} does not match input symbol ${r}")
                    return
                }
            }
            else{
                if(!parseTable[X].contains(r)) {
                    println("Error: no rule for M[${X}, ${r}]")
                    return
                }
                let prod = parseTable[X][r]
                stack.remove(at: stack.size - 1)
                // 将产生式体逆序入栈
                for(i in prod.size-1..=0:-1) {
                    if(prod[i] != String(r"ε")) {
                        stack.add(prod[i])
                    }
                }
                showStep(stack, strs, "${X} -> ${String.join(prod.toArray())}", countStep)
            }
        }
    }
}