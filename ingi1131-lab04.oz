
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
declare X Y Z W in 
X = h | Z
thread {PassingTheToken 1 X Y} end
thread {PassingTheToken 2 Y W} end
thread {PassingTheToken 3 W X} end


% Ex 4
% Here is a version where Bar continues to server beers.
% Not what we need
declare 
fun {Bar C}
   {Delay 500}
   {Show 'Beer delivered'#C}
   beer|{Bar C+1}
end

fun {Foo In C}
   case In of H|T then
      {Delay 1200}
      {Show 'Beer drunk'#C}
      {Foo T C+1}
   end
end


% {Browse {Bar}} % why doens't this work?
declare Beers Result in
Beers = thread {Bar 0} end
Result = thread {Foo Beers 0} end

% Here is a version where Bar serves a beer as soon as Foo requests it.
% Not yet there, but closer
% You can see that Foo is waiting for beers to be delivered
declare 
fun {Bar C In}
   case In of H|T then
      {Delay 500}
      {Show 'Beer delivered'#C}
      H=beer
      {Bar C+1 T}
   end
end

fun {Foo In C}
   local H T in
      In=H|T
      {Show 'Waiting for beer'#C}
      {Wait H}
      {Delay 1200}
      {Show 'Beer drunk'#C}
      {Foo T C+1}
   end
end


% {Browse {Bar}} % why doens't this work?
declare Beers Result in
Beers = thread {Bar 0 Beers} end
Result = thread {Foo Beers 0} end
	

% Bounded Buffer
% Correct version
declare 
proc {Bar C In}
   case In of H|T then
     {Delay 1000}
      {Show 'Beer delivered'#C}
       H=beer
      {Bar C+1 T}
   end
end
proc {MBuffer In N Out}
   fun {Startup N In}
      if N==0 then
	 {Show 'Done initialising buffer'}
	 In
      else T in
	 {Show 'adding entry in buffer initialisation'}
	 In=_|T
	 {Startup N-1 T}
      end
   end
   proc {BufferLoop In Out End}
      case Out of Ho|To then Hi Ti End2 in
	 In=Hi|Ti
	 Ho=Hi
	 End=_|End2
	 thread {BufferLoop Ti To End2} end
      end
   end   
   {Show 'will call startup'}
   Ctrl = {Startup N In}
in
   {BufferLoop In Out Ctrl}
end
fun {Foo In C}
   local H T in 
      H|T=In
      if H==beer then
	 {Show 'Got beer'#C}
	 {Delay 4000}
	 {Show 'Beer drunk'#C}
	 {Foo T C+1}
      end
   end
end
% This works as expected
declare Beers ServedBeers Buffer Result in
thread {Bar 0 Beers} end
thread {MBuffer Beers 4 ServedBeers}end
Result = thread {Foo ServedBeers 0} end
{Browse Result}
{Browse ServedBeers}
{Browse Beers}


	
%5
% Create a chain of assignments
declare
proc {MapRecord R1 F R2 Done}
   A={Record.arity R1}
   proc {Loop L ?ThreadDone}
      case L of nil then ThreadDone=unit
      [] H|T then NewDone in
	 thread R2.H={F R1.H} ThreadDone=NewDone end
	 {Loop T NewDone}
      end
   end
in
   R2={Record.make {Record.label R1} A}
   {Loop A Done}
end
Done Result
{MapRecord
       '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
       fun {$ X} {Delay 1000} 2*X end Result Done}
{Wait Done}
{Show Result}

