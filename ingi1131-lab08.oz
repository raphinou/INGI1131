declare
proc {ReadList L}
   case L of H|T then
      {Browse H}
      {ReadList T}
   [] nil then skip
   end
end
{ReadList [ 1 2 3 45 ]}


declare
P S
{NewPort S P}
{Send P foo}
{Send P bar}
thread {ReadList S} end
proc {RandomSenderManiac N P}
   proc {MySender I}
      if I<N then
	 thread
	    {Delay ({OS.rand}mod (3000-1000-1000))+1000}
	    {Send P I}
	 end
	 {MySender I+1}
      else
	 skip
      end
   end
in
      {MySender 0}
end
{RandomSenderManiac 5 P}



%6
declare
P S A B
{NewPort S P}
fun {WaitTwo X Y}
   thread  {Wait X}  {Send P x} end
   thread {Wait Y}  {Send P y} end
%    thread if X==0 then {Send P x} else {Send P x} end end
%    thread if Y==0 then {Send P y} else {Send P y} end end
   thread 
      case S of x|_ then 1
      [] y|_ then 2
      end
   end
end
{Browse {WaitTwo A B}}
B=1
 



%7
declare S P
{NewPort S P}
proc {Server S}
   case S of (Msg#Ack)|T then
      {Delay ({OS.rand} mod (3000-1000-1000))+1000}
      Ack=unit
      {Server T}
   end
end
thread {Server S} end
{Browse S}
% execute this local block to send a msg to the server
local X in 
   {Send P hello#X}
end
fun {WaitTwo X Y}
   local P S in
      {NewPort S P}
      thread  {Wait X}  {Send P x} end
      thread {Wait Y}  {Send P y} end
      thread 
	 case S of x|_ then 1
	 [] y|_ then 2
	 end
      end
   end
end
#better:
fun {WaitTwo X Y}
   S
   P={NewPort S}
in
   thread {Wait X} {Send P 1} end
   thread {Wait Y} {Send P 2} end
   S.1
end
fun {SaveSend P M T}
   local Ack Timeout in
      {Send P M#Ack}
      thread {Delay T} Timeout=unit end   
      if {WaitTwo Ack Timeout}==1 then
	 true
      else
	 false
      end
   end
end
{Browse {SaveSend P test 3000}}
%10
declare
fun {WaitTwo X Y}
   local P S in
      {NewPort S P}
      thread  {Wait X}  {Send P x} end
      thread {Wait Y}  {Send P y} end
      thread 
	 case S of x|_ then 1
	 [] y|_ then 2
	 end
      end
   end
end
fun {StreamMerger S1 S2}
   local H1 T1 H2 T2 in
      S1=H1|T1
      S2=H2|T2
      if {WaitTwo H1 H2}==1 then
	 H1 | {StreamMerger T1 S2}
      else
	 H2 | {StreamMerger S1 T2}
      end
   end
end
local X Y Z T T2 in
   {Browse Z}
   thread Z ={StreamMerger 1|2|X 3|4|Y} end
   {Delay 1000}
   X=9|T
   {Delay 1000}
   Y=10|11|T2
end
