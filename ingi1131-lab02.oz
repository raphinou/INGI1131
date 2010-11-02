% Lab 2

%1.a

declare Max in 

fun {Max L}
   fun {MaxLoop L M}
      case L of nil then M
      [] H|T then
	 if M>H then {MaxLoop T M}
	 else {MaxLoop T H} end
      end
   end
in
   if L == nil then error
   else {MaxLoop L.2 L.1} end
end
% Why does this call raise an error? (Illegal arity, found 1, expected 2)
% Answer: it is because we have a function, that returns a value. 
% It is translated in the kernel language as a call to a procedure with an additional argument
% which is the variable to which the result of the call is assigned. As it is not present, 
% it raises an arity error.
%{Max [ 4 2 6 4 8 ]}
% This works
{Browse {Max [ 4 2 6 4 8]} }

declare MaxProc Result in
proc {MaxProc L ?M}
   proc {MaxProcLoop L ?M ?R}
      case L of nil then R=M
      [] H|T then
	 if M>H then { MaxProcLoop T M R}
	 else {MaxProcLoop T H R } end
      end
   end
in
   if L==nil then skip
   else {MaxProcLoop L.2 L.1 M} end
end
{MaxProc [ 2 5 9 5 7 3] Result}
{Browse Result }
   

% Better solution:
declare
fun {Facts N}
   fun {FactsIn N0 N1 N2}
      if N0<N then
	 N1|{FactsIn N0+1 N2 N2*(N0+3)}
      else
	 nil
      end
   end
in
   {FactsIn 0 1 2}
end

% My original solution, cumbersome:
% Beware: Append takes 2 lists as argument!!
declare Fact in
fun {Fact N}
   fun {FactLoop I A}
      if I==N then
	 A
      else
	 {FactLoop I+1 {Append A [{Nth A {Length A}}*I] }  }
      end 
   end
in
   {FactLoop 1 [1]}
end

{Browse {Fact 10} }
{Browse {Append [1] 1}}
{Browse [1 1]}
{Browse {Length 1|1|nil}}
local A in
   A=[1 2 3 4 5]
   {Browse {Append A {Nth A {Length A}}*3} }
end



%2.A

% Not tail recursive because call to the function is not the last operation. The last operation in the function call is +
% Solution: invert the operands
fun {Sum N}
   if N==0 then 0
   else {Sum N-1} + N
   end
end
Can be rewritten with an accumulator.

%2.b
i% tail recursive, as we build a data structure, which can use unbound variables. 

% Problem with missing else clause?? line 77. matching [1 2]#[3 4] shold be fine, no?
declare MyAppend in
fun {MyAppend L1 L2}
   fun {AppendAcc L1 L2 Acc}
     case L1#L2 of
	nil#nil then Acc
     [] nil#L2 then {AppendAcc L2 nil Acc}
     [] L1#_ then {AppendAcc L1.2 L2 L1.1|Acc}
     end
   end
in
   {Reverse {AppendAcc L1 L2 nil}}
end
{Browse {MyAppend [1 2 b ] [3 4]}}
  

%3.a

local
   X Y
in
   {Browse 'hello nurse'}
   X = 2 + Y
   {Browse X}
   Y = 4
end

% waits for Y to be bound before browsing X. Similarity with Sum: before returning, it will wait to have the value of both operands of +.


%3.b
% ################## I don't know ###############
%This is not a function call! we build a data structure which can use unbound variables.
local
   X Y
in
   {Browse '1'}
   X = sum(2 Y)
   {Browse X}
   Y=40
   {Browse X}
end



%4.1
declare ForAllTail Pairs in
proc {Pairs L E}
   case L of H|T then
      {Browse pair(H E)}
      {Pairs T E}
      else skip
   end
end
proc {ForAllTail Xs P}
   case Xs of  H|T then
      {P Xs}
      {ForAllTail T P}
      else skip
   end
end
{ForAllTail [a b c d] proc {$ Tail}
                         {Pairs Tail.2 Tail.1}
                      end }

%3.b
%A working solution
%Note: use Append to append to the list
%When doing Head|Tail , Head will be one element of the list,
%so if Head=[1 2 3 4] and Tail is [5 6 7] 
% Head|Tail will give [[1 2 3 4] 5 6 7]
declare
Tree = tree(info:10
	    left:tree(info:7
		      left:nil
		      right:tree(info:9
				 left:nil
				 right:nil))
	    right:tree(info:18
		       left:tree(info:14
				 left:nil
				 right:nil)
		       right:nil))
declare GetElementsInOrder in
fun {GetElementsInOrder Tree}
   fun {GEIOAcc Tree Acc}
      case Tree of nil then Acc
      [] tree(info:Info left:L right:R) then
	 {Append {Append {GEIOAcc L Acc} [Info]}{GEIOAcc R Acc}}
      end
   end
   Result=nil
in
   {GEIOAcc Tree Result}
end
{Browse {GetElementsInOrder Tree}}





{Browse {Append [1] [1 2]}}

%5

declare Fib in
fun {Fib N}
   if N<2 then 1
   else
      {Fib N-1}+ {Fib N-2}
   end
end
{Browse {Fib 35}}

declare Fib2 FibAcc in
fun {Fib2 N}
   fun {FibAcc N Acc1 Acc2}
      if N<2 then Acc2
      else
	 {FibAcc N-1  Acc2 Acc1+Acc2}
      end
   end
in
   {FibAcc N 1 1}
end
{Browse {Fib2 100}}


%6
%question: is it ok to use Reverse??
declare Add AddDigits in
fun {AddDigits D1 D2 CI}
   case D1+D2+CI of 1 then output(sum:1 carry:0)
   [] 2 then output(sum:0 carry:1)
   [] 0 then output(sum:0 carry:0)
   [] 3 then output(sum:1 carry:1)
   end
end
fun {Add B1 B2}
   fun {AddAcc B1 B2 S C}
      case B1 of nil then {Append S [C]}
      else
	 local Result in 
	    Result = {AddDigits B1.1 B2.1 C}
	    {Browse S}
	    {AddAcc B1.2 B2.2 {Append S [Result.sum]}  Result.carry}
	 end
      end
   end
in
   {Reverse {AddAcc {Reverse B1} {Reverse B2} nil 0}}
end

{Browse {Add [ 1 1 0 1 1 0] [0 1 0 1 1 1]}}

{Browse {AddDigits 1 1 1}}

local T in
   T=test(f:1 s:2)
   {Browse T.f}
end




%7

declare Filter FF in
fun {Filter L F}
   case L of nil then nil
   else
      if {F L.1} then L.1|{Filter L.2 F}
      else {Filter L.2 F} 
      end
   end      
end
fun {FF I}
   I<3
end

{Browse {Filter [1 2 3 4 5 6 7] FF}}
{Browse {Filter [1 2 3 4 5 6 7] fun {$ I} I>4 end}}
{Browse {FF 4}}



%10
% There is certainly a better solution this, but this works
declare
fun {Flatten L}
   fun {FlattenAcc L Acc}
      case L of H|nil then
	 {FlattenAcc H Acc}
      [] H|T then
	 %{FlattenAcc H Acc}
	 {FlattenAcc T {FlattenAcc H Acc}}
      [] nil then Acc
      else
	 L|Acc
      end
   end
in
   {Reverse {FlattenAcc L nil}}
end
{Browse {Flatten [a [b [c d]] e [[[f]]]]} }o

% This uses accumulators.
declare
fun {Flatten L}
   fun {FlattenAcc L Acc}
      case L of H|nil then
	 {FlattenAcc H Acc}
      [] H|T then
	 {FlattenAcc T {FlattenAcc H Acc}}
      [] nil then Acc
      else
	 {Append Acc [L]}
      end
   end
in
   {FlattenAcc L nil}
end
{Browse {Flatten [a [b [c d]] e [[[f]]]]} }
