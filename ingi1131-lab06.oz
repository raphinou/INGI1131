%Ex1

declare
fun lazy {Gen I}
   I | {Gen I+1}
end
declare X in 
X={Gen 5}
{Browse X}   
{Browse X.2.2.2.1}
{Browse X}

declare
fun {GiveMeNth N L}
   if N==1 then L.1
   else {GiveMeNth N-1 L.2}
   end
end

{Browse {GiveMeNth 1 X}}

%2
declare
fun lazy {Filter Xs P}
   case Xs of
      nil then nil
   [] X|Xr then
      if {P X} then
	 X|{Filter Xr P}
      else
	 {Filter Xr P}
      end
   end
end
fun lazy {Sieve Xs}
   case Xs of nil then nil
   [] X|Xr then
      X|{Sieve {Filter Xr fun {$ Y} Y mod X \= 0 end}}
   end
end
%validate with http://primes.utm.edu/lists/small/1000.txt
declare P
P={Sieve {Gen 2}}
{Browse {GiveMeNth 1000 P}}

declare
fun {ShowPrimes N}
   fun {BrowseList L N}
      if N==0 then
	 nil
      else
	 L.1  | {BrowseList L.2 N-1}
      end
   end
in
   {BrowseList {Sieve {Gen 2}} N}
end
{Browse {ShowPrimes 10}}

% this version shows the primes in the console
declare
fun {ShowPrimes2 N}
   fun {BrowseList L N}
      if N==0 then
	 nil
      else
	 {Show L.1}
	 {BrowseList L.2 N-1}
      end
   end
in
   {BrowseList {Sieve {Gen 2}} N}
end
{Browse {ShowPrimes2 10}}


%4
declare
fun {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun {Filter L F}
   case L of nil then nil
[] H|T then
   if {F H} then H|{Filter T F} else {Filter T F} end
end
end
fun {Map L F}
   case L of nil then nil
[] H|T then {F H}|{Map T F}
end
end

%A version with thread ... end
declare Xs Ys Zs
{Browse Zs}
Xs=thread {Gen 1 100} end
Ys= thread {Filter Xs fun {$ X} (X mod 2)==0 end} end
Zs = thread {Map Ys fun {$ X} X*X end} end

% Lazy functions


declare
fun lazy {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun  lazy {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end
fun  {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end


declare Xs Ys Zs
{Browse Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}
% la fonction du dernier appel ne doit pas etre lazy, sinon rien ne se passe. En effet, aucun element n'est utilisé -> aucun calcul.

