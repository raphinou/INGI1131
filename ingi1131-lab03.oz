%2
%-

declare Guess Y in 
proc  {Guess X}
   if X==42 then skip else skip end
   {Browse 'finish guess'}
end

thread {Guess Y} end

Y=3
   


%3

DCAB
ABCD

%4

%2 thread avec liste de longueur n/2
% 4 thread avec longueur de liste n/4
% 8 thread avec longueur de list n/8

%pour 2 el -> 2 threads
% pour 4 el -> 6 threads
% pour 8 el -> 14 threads

% -> 2*(n-1) pour les n pairs.

% pour n impair?



%6
declare
fun {Ints N Max}
   if N>Max then nil
   else N|{Ints N+1 Max}
   end
end
fun {FilterOdd L}
   case L of H|T then
      if H mod 2 == 0 then {FilterOdd T}
      else H|{FilterOdd T}
      end
      [] nil then nil
   end
end
fun {Consumer L Acc}
   case L of H|T then {Consumer T Acc+H}
      [] nil then Acc
   end
end
I= thread {Ints 0 100} end
Odds = thread {FilterOdd I} end
Sum = {Consumer Odds 0} 
{Browse I}
{Browse Odds}
{Browse Sum}

%5
declare Prod Cons in 
fun {Prod N}
   fun {ProdAcc C N}
      {Delay 400}
      if C==N+1 then nil
      else
	 C|{ProdAcc C+1 N}
      end
   end
in
   
      {ProdAcc 1 N}
 
end

fun {Cons L}
   fun {ConsAcc L Acc}
      case L of nil then Acc
      [] H|T then {ConsAcc T Acc+H}
      end
   end
in
   {ConsAcc L 0}
end

declare
fun {Filter L}
   case L of nil then nil
   [] H|T then
      if  H mod 2==1 then
	 H|{Filter T}
      else
	 {Filter T}
      end
   end
end

   
declare X X2 Y in 
thread X = {Prod 20} end
thread X2  = { Filter X} end
thread Y = {Cons  X2 } end

{Browse X}
{Browse X2}


%6  
