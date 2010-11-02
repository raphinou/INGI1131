declare
fun  {Numbers N I J}
   {Delay 250}
   if N==0 then nil
   else ({OS.rand} mod (J-I+1)+I)|{Numbers N-1 I J}
   end
end

{Browse {Numbers 10 0 1}}
{Browse 4 }


%declare
%fun {SumAndCount L}
%   fun {SumAndCountAcc L Sum Count}
%      {Delay 250}
%      case L of nil then Sum#Count
%      [] H|T then {SumAndCountAcc T Sum+H Count+1}
%      end
%   end
%in
%   {SumAndCountAcc L 0 0}
%end

declare
fun {SumAndCount L}
   fun {SumAndCountAcc L Sum Count}
      {Delay 250}
      case L of nil then nil
      [] H|T then Sum+H#Count+1|{SumAndCountAcc T Sum+H Count+1}
      end
   end
in
   {SumAndCountAcc L 0 0}
end

{Browse {SumAndCount {Numbers 10 3 10}} }

%c
% teta de n
local X Y in
   thread X = {Numbers 10 3 10} end
   thread Y = {SumAndCount X} end
   {Browse X}
   {Browse Y}
end

%d
declare 
fun {Includes?   L E }
   case L of H|T then if E==H then true else {Includes? T E} end 
   [] nil then false
   end
end

 

%declare
%fun {FilterList Xs Ys}
%   fun {FilterListAcc Xs Ys Res}
%      case Xs of nil then Res
%      [] H|T then if {Includes?  Ys H} then {FilterListAcc T Ys Res}
%		  else {FilterListAcc T Ys H|Res}
%		  end
%      end
%   end
%in
%      {FilterListAcc Xs Ys nil}
%end


declare
fun {FilterList Xs Ys}
      case Xs of nil then nil
      [] H|T then if {Includes?  Ys H} then {FilterList T Ys}
		  else H|{FilterList T Ys}
		  end
	 
      
      end
end

{Browse {FilterList [ 1 2 3 4 5] [ 2 ]}}


%e

local X Y Z in
   thread X = {Numbers 20 0 30} end
   thread Y = {FilterList X [ 0 1 2 3 4 5 6 7 8 9 ] } end
   thread Z = {SumAndCount Y} end
   {Browse X}
   {Browse Y}
   {Browse Z}
end


%2



declare
fun {MNot I}
   (I+1) mod 2
end


{Browse {MNot 0}}
declare
fun {NotGate L}
   case L of nil then nil
   [] H|T then {MNot H}|{NotGate T}
   end
end

{Browse {NotGate 1|1|0|0|0|1|nil}}

declare
fun {MAnd I1 I2}
   if I1==1 andthen I2==1 then 1
   else 0 end
end
declare     
fun {AndGate L1 L2}
   case L1 of nil then nil
   [] H1|T1 then
      case L2 of nil then nil
      [] H2|T2 then
	 {MAnd H1 H2}|{AndGate T1 T2}
      end
   end
end

declare
fun {MOr I1 I2}
   if I1==1 orelse I2==1 then 1
   else 0 end
end

declare
fun {OrGate L1 L2}
   case L1 of nil then nil
   [] H1|T1 then
      case L2 of nil then nil
      [] H2|T2 then
	 {MOr H1 H2}|{OrGate T1 T2}
      end
   end
end

{Browse gate(value:'or' g1 g2 g3 g4)}

declare
fun {Simulate G Ss}
   case G of gate(value:'not' In) then
      thread {NotGate {Simulate In Ss}} end
   [] gate(value:'and' In1 In2) then
      thread {AndGate {Simulate In1 Ss} {Simulate In2 Ss}} end
   [] gate(value:'or' In1 In2) then
      thread {OrGate {Simulate In1 Ss} {Simulate In2 Ss}} end
   [] input(Input) then
      Ss.Input
   end
end

{Simulate gate(value:'or' gate(value:'and' [1 0] [0 1]) gate(value:'not' [ 1 1 ]))}


local G in
%   G=gate(value:'and' input(x) input(y))
%   G=gate(value:'or' input(x) input(y))
   G=gate(value:'or'    gate(value:'or' input(x) input(y))  input(z))
   {Browse {Simulate G input(x:1|0|1|1|1|0|0|_ y:0|1|1|1|1|1|1|_ z:1|0|0|1|0|1|1|_)}}
end

declare T
T = gate(value:3 l:left)



%3 Thread termination
%a
declare
L1 L2 F Ok
L1 = [1 2 3]
F = fun {$ X} {Delay 200} X*X end
thread L2 = {Map L1 F} Ok=done end
{Wait Ok}
{Show L2}


%b
declare
L1 L2 L3 L4 Ok1 Ok2 Ok3
L1 = [1 2 3]
thread L2 = {Map L1 fun {$ X} {Delay 200} X*X end} Ok1=done end
thread L3 = {Map L1 fun {$ X} {Delay 400} 2*X end} Ok2=Ok1 end
thread L4 = {Map L1 fun {$ X} {Delay 600} 3*X end} Ok3=Ok2 end
{Wait Ok3} % We have to wait for Ok3 here! Waiting here for Ok1 is not right!
{Show L2#L3#L4}

%c
declare Result Ok
proc {MapRecord Ok R1 F R2 }
   A={Record.arity R1}
   proc {Loop L}
      MyOk in
      case L of nil then skip
      [] H|T then
	 thread R2.H={F R1.H}
	    if T==nil then
	       Ok=done % when the last thread has finished, it sets the Ok variable passed as argument to done,
	    else       % and, as threads dinish, this will bubble up to the Ok variable passed as argument
	       MyOk=Ok end  
	 end                              
	 {Loop T}
      end
   end
in
   R2={Record.make {Record.label R1} A}
   {Loop A}
end

Result= {MapRecord Ok
	 '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
	 fun {$ X} {Delay 1000} 2*X end}
{Wait Ok}
{Show Result}






% d.ii

declare
proc {Buffer N ?Xs Ys}
   fun {Startup N ?Xs}
      if N==0 then Xs
      else Xr in Xs= _|Xr {Startup N-1 Xr} end
   end
   proc {AskLoop Ys ?Xs ?End}
      case Ys of Y|Yr then
	 Xr End2
      in
	 Xs=Y|Xr % Get element from buffer
	 End=_|End2 % Replenish the buffer
	 {AskLoop Yr Xr End2}
      end
   end
   End={Startup N Xs}
in
   {AskLoop Ys Xs End}
end
proc {DGenerate N Xs}
   case Xs of X|Xr then X=N {DGenerate N+1 Xr} end
end
fun {DSum01 ?Xs A Limit}
   {Delay 5000}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum01 Xr A+X Limit-1}
   else A end
end
fun {DSum02 ?Xs A Limit}
   {Delay 1000}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum02 Xr A+X Limit-1}
   else A end
end
local Xs Ys Zs V1 V2 in
   thread {DGenerate 1 Xs} end % Producer thread
   thread {Buffer 4 Xs Ys} end % Buffer thread
   thread {Buffer 1 Ys Zs} end % Buffer thread
   thread V1={DSum01 Zs 0 15} end % Consumer thread
   thread V2={DSum02 Zs 2 15} end % Consumer thread
   {Browse x#Xs}
   {Browse y#Ys}
   {Browse z#Zs}
   {Browse v1#V1}
   {Browse v2#V2}
end
