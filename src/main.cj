package lab3

import std.env.*
import std.collection.*

main(): Int64 {
    let consoleReader = getStdIn()
    let strs = ArrayList<String>()
    while(true) {
        var str = (consoleReader.readln()) ?? ""
        // println("Read line: " + str)
        if(str.isEmpty()) {
            break
        }
        else{
            str += "|"
            strs.add(str)
        }
    }
    
    let grammar = Grammar(strs)
    println("Original grammar:")
    grammar.print()

    grammar.eliminateLeftRecursion()
    println("After eliminating left recursion:")
    grammar.print()

    grammar.eliminateLeftFactor()
    println("After eliminating left factor:")
    grammar.print()

    grammar.computeFirstSet()
    grammar.computeFollowSet()
    grammar.computedFirstAndFollow = true
    grammar.print()

    let checkLL1Result = grammar.checkLL1()
    println("check LL(1): ${checkLL1Result}")
    if(checkLL1Result) {
        grammar.computeParseTable()
        print("Input a string to analyze: ")
        var inputStr = (consoleReader.readln()) ?? ""
        let runeArrayOfStr = inputStr.toRuneArray()
        let stringListOfStr = ArrayList<String>()
        for(r in runeArrayOfStr) {
            stringListOfStr.add(r.toString())
        }
        stringListOfStr.add("$") // 添加结束符
        grammar.analyze(stringListOfStr)
    }

    return 0
}