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




%5
declare
fun lazy {Insert X Ys}
   {Show iiiiiiiiii}
   case Ys of
      nil then [X]
   [] Y|Yr then
      if X < Y then
	 X|Ys
      else
	 Y|{Insert X Yr}
      end
   end
end
fun lazy {InSort Xs} %% Sorts list Xs
   {Show ooooooo}
   case Xs of
      nil then nil
   [] X|Xr then
      {Insert X {InSort Xr}}
   end
end
fun {Minimum Xs}
   {InSort Xs}.1
end
Result={Minimum [3 2 1 4]}


{Show Result}

%Complexity n²
[3 2 1 4]
{Insert 3
 {Insert 2
   {Insert 1
    {Insert 4 {Insort nil}}}}
 % n going down
 % n going up

%  Complexity of lazy version is n.
% Insert compare son premier argument à la tete de la liste -> il ne calcule qu'un élément de la liste.


 %6
% Comme on fait un last, il faut calculer toute la liste -> pas d'avantage.

 
 
 %8
 declare
 fun {Buffer In N}
    End=thread {List.drop In N} end
    fun lazy {Loop In End}
       case In of I|In2 then
	  I|{Loop In2 thread End.2 end}
       end
    end
 in
    {Loop In End}
 end
declare
fun lazy {DGenerate N}
      N|{DGenerate N+1}
end
fun {DSum01 ?Xs A Limit}
   if Limit>0 then
      {Delay {OS.rand} mod 10}
      {DSum01 Xs.2 A+Xs.1 Limit-1}
   else A end
end
fun {DSum02 ?Xs A Limit}
   {Delay {OS.rand} mod 10}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum02 Xr A+X Limit-1}
   else A end
end
local Xs Ys V1 V2 in
    {DGenerate 1 Xs} % Producer thread
    {Buffer Xs 4 Ys}  % Buffer thread
   thread V1={DSum01 Ys 0 100} end % Consumer thread
   thread V2={DSum02 Ys 2 100} end % Consumer thread
   {Browse [Xs Ys V1 V2]}
end