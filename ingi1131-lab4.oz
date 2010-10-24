
% ex 1


declare
fun {IncrementorAcc C L}
   case L of (Char#Count)|T then
      if Char==C then
	 Char#(Count+1) | T
      else
	 Char#Count|{IncrementorAcc C T }
      end
   else
      C#1|nil
   end
end
declare
fun {Counter L}
   fun {CounterAcc L Counter}
      case L of H|T then
	 local NewCounter in
	    NewCounter ={IncrementorAcc H Counter}
	    Counter|{CounterAcc T NewCounter}
	 end
      else
	 nil
      end
   end
in
   {CounterAcc L nil}
end

declare
fun {RandomChar}
   local N Chars in
      Chars = rec(a b c d e)
      N=({OS.rand} mod 5) +1
      Chars.N
   end
end
declare 
fun {Mine N}
   {Delay 2000}
   if N==0 then
      nil
   else
      {RandomChar}|{Mine N-1}
   end
end

   

%{Browse {IncrementorAcc 'c' [a#1 c#3] }}
      
%{Browse {Counter ['r' 'c'  'r' 'd' 'r' ]}}

declare M N in 
thread M={Mine 5} end
thread N={Counter M} end
{Browse M}
{Browse N}





% Ex 3
declare
proc {PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Show Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   [] nil then
      skip
   end
end
declare X Y Z in 
X = h | Z
thread {PassingTheToken 1 X Y} end
thread {PassingTheToken 2 Y Z} end
thread {PassingTheToken 3 Z X} end

   