% 1
% In emulator, it doesn't show the right results, but if you browse rather than show the results, you can see it works fine.
declare
fun {LaunchServer}
   P S 
   proc {Loop Stream}
      case Stream of add(X Y R)|T then
	 R=X+Y
	 {Loop T} 
      [] pow(X Y R)|T then
	 R={Pow X Y}
	 {Loop T}
      [] 'div'(X Y R)|T then
	 R= X div Y
	 {Loop T}
      else
	 {Show 'message not understood'}
      end
   end	 
in
   P={NewPort S}
   thread {Loop S} end
   P
end   
declare
A B N S
Res1 Res2 Res3 Res4 Res5 Res6
S = {LaunchServer}
{Send S add(321 345 Res1)}
{Show Res1}
{Browse Res1}
{Send S pow(2 N Res2)}
N=8
{Show Res2}
{Browse Res2}
{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
{Show Res4}
A=3
B = 0-A
{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{Show Res3}
{Show Res5}
{Show Res6}



%2
declare
fun {StudentRMI}
   S
in
   thread
      for ask(howmany:Beers) in S do
	 Beers = {OS.rand} mod 24
      end
   end
   {NewPort S}
end
fun {StudentCallBack}
   S
in
   thread
      for ask(howmany:P) in S do
	 {Send P {OS.rand} mod 24}
      end
   end
   {NewPort S}
end
fun {CreateUniversity Size}
   fun {CreateLoop I}
      if I =< Size then
	 {StudentRMI}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   %% Kraft dinner is full of love and butter
   {CreateLoop 1}
end
proc {LoopStudents L}
   case L of H|T then
      local Amount in 
	{Send H ask(howmany:Amount)}
	{Browse Amount}
     end
      {LoopStudents T}
   end
end
{LoopStudents {CreateUniversity 100}}

% Better I think:
declare
fun {Student}
   {StudentRMI}
end
fun {StudentRMI}
   S
in
   thread
      for ask(howmany:Beers) in S do
	 Beers = {OS.rand} mod 24
      end
   end
 {NewPort S}
end
fun {CreateUniversity Size}
   fun {CreateLoop I}
      if I =< Size then
	 {Student}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   %% Kraft dinner is full of love and butter
   {CreateLoop 1}
end
fun {FoldL S Fun State}
   case S of H|T then
      {FoldL T Fun {Fun H State}}
   [] nil then State
   end
end
Uni={CreateUniversity 10}
{Browse Uni}
fun {Counter N State}
      case State of c(total:Total minimum:Minimum maximum:Maximum count:Count) then
	 c(total:Total+N
	   minimum:(if N<Minimum then N else Minimum end)
	   maximum:(if N>Maximum then N else Maximum end)
	   count:Count+1)
      end
end
Ans={Map Uni fun {$ I} {Send I ask(howmany:$)} end }
{Browse Ans}
{Browse {FoldL Ans Counter c(total:0 minimum:10000 maximum:0 count:0)}}



%3
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end
fun {PorterCounter Msg Count}
   case Msg of getIn(N) then Count+N
   [] getOut(N) then Count-N
   [] getCount(N) then
      N=Count
   else
      Count
   end
end
Porter = {NewPortObject PorterCounter 0}
local R in
   {Browse R}
   {Send Porter getIn(53)}
   {Send Porter getOut(2)}
   {Send Porter getCount(R)}
end

%4
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end
fun {StackBehaviour Msg State}
   case Msg of push(X) then
      X|State
   [] pop(X) then
      if State==nil then
	 X=nil
      else
	 X=State.1
	 State.2
      end
   [] isEmpty(X) then
      if State==nil then X=true else X=false end
      State
   else
      State
   end
end
proc {Push S X}
   {Send S push(X)}
end
fun {Pop S}
   X in 
   {Send S pop(X)}
   {Wait X}
   X
end
fun {IsEmpty S}
   X in
   {Send S isEmpty(X)}
   {Wait X}
   X
end
fun {NewStack}
   {NewPortObject StackBehaviour nil}
end
declare
Stack = {NewStack}
{Push Stack s}
{Push Stack t}
{Push Stack u}
{Browse {IsEmpty Stack}}
{Browse {Pop Stack}}

%5
declare
fun {QueueBehaviour Msg Q}
   case Msg of enqueue(X) then
      {Append Q [X] }
   [] dequeue(X) then
      case Q of H|T then
	 X=H
	 T
      else
	 X=nil
      end
   end
end
proc {Enqueue Q X}
   {Send Q enqueue(X)}
end
fun {Dequeue Q}
   X in
   {Send Q dequeue(X)}
   X
end
Q={NewPortObject QueueBehaviour nil}
{Enqueue Q s}
{Enqueue Q t}
{Enqueue Q u}
{Browse {Dequeue Q}}


