Input Format:
------------

Input your grammar in the "input.txt" file
Use uppercase letters for non-terminals.
Use "%" (without quotes) for single line comments in the "input.txt" file.
You can use {[a-z], +, x , (, ), Epsilon} for terminals characters.
Use "ε" or "∈" (without quotes) for epsilon/null production.
Use "→" or "->" to denote a production.
Use "|" or " / " for separating multiple productions.
Start symbol is always "S". If your input does not have "S" as the start symbol, add a production 'S -> "Your start symbol"'

E.g. : 
------

	% this is a sample input.
	S →E					% since E was the original start symbol, S->E is added.
	E → E + T / T
	T → T x F / F
	F → b


Execution:
----------
Install Flex and g++.
Run the command "lex isLL1.l" (without quotes).
A file with name "lex.yy.c" is created.
Run the command "g++ lex.yy.c -ll" (without quotes).
The above command will generate an "a.out" binary file.
Run the command "./a.out" (without quotes) to get the desirable output.


Output Format:
--------------

E.g.: Output for the above grammar
-----

	Our grammar:
	S →  E
	E →  E+T|T
	F →  b
	T →  TxF|F
	------------

	After removing left recursion:
	S →  E
	E →  TE'
	E' →  +TE'|ε
	F →  b
	T →  bT'
	T' →  xFT'|ε
	------------

	After removing left factoring:
	S →  E
	E →  TE'
	E' →  +TE'|ε
	F →  b
	T →  bT'
	T' →  xFT'|ε
	------------

	Our parse table:

	current variable [S]:
		 current input token = {$}, possible rules are: {}
		 current input token = {b}, possible rules are: {S →  E}
		 current input token = {+}, possible rules are: {}
		 current input token = {x}, possible rules are: {}

	current variable [E]:
		 current input token = {$}, possible rules are: {}
		 current input token = {b}, possible rules are: {E →  TE'}
		 current input token = {+}, possible rules are: {}
		 current input token = {x}, possible rules are: {}

	current variable [E']:
		 current input token = {$}, possible rules are: {E' →  ε}
		 current input token = {b}, possible rules are: {}
		 current input token = {+}, possible rules are: {E' →  +TE'}
		 current input token = {x}, possible rules are: {}

	current variable [F]:
		 current input token = {$}, possible rules are: {}
		 current input token = {b}, possible rules are: {F →  b}
		 current input token = {+}, possible rules are: {}
		 current input token = {x}, possible rules are: {}

	current variable [T]:
		 current input token = {$}, possible rules are: {}
		 current input token = {b}, possible rules are: {T →  bT'}
		 current input token = {+}, possible rules are: {}
		 current input token = {x}, possible rules are: {}

	current variable [T']:
		 current input token = {$}, possible rules are: {T' →  ε}
		 current input token = {b}, possible rules are: {}
		 current input token = {+}, possible rules are: {T' →  ε}
		 current input token = {x}, possible rules are: {T' →  xFT'}
	-----
	RESULT: This grammar is LL1