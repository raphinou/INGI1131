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

	 