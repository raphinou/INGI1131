%1
declare
A={NewCell 0}
B={NewCell 0}
T1=@A
T2=@B
{Show A==B} % a: What will be printed here
% true, false, A, B or 0?
{Show T1==T2} % b: What will be printed here
% true, false, A, B or 0?
{Show T1=T2} % b: What will be printed here
% true, false, A, B or 0?
A:=@B
{Show A==B} % b: What will be printed here
% true, false, A, B or 0?


%2
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
fun {MyNewCell}
   {NewPortObject fun {$ Msg State}
		     case Msg of assign(Value) then
			Value
		     [] access(Return) then
			Return=State
			State
		     end
		  end
    nil }
end
proc {Assign C R}
   {Send C assign(R)}
end
proc {Access C R}
   {Send C access(R)}
end
declare
Return R2
MyCell={MyNewCell}
{Assign MyCell 3}
{Access MyCell Return}
{Browse Return}
{Browse R2}

{Assign MyCell 5}
{Access MyCell R2}

%3
declare
L P
%{Browse L}
%{NewPort L P}
%{Send P first}
fun {CNewPort L}
   {NewCell nil}
end
proc {CSend P Msg}
   case {Access P} of nil
      then
      {Assign P {Append {Access P} [Msg _]}}
   []  H|T
   then
      {Browse h#H}
      {Browse t#T}
      {Browse msg#Msg}
      T={Append T Msg}
   end   
end
{CNewPort L P}
{CSend P tesxr}
{Browse {Access P}}

%5
declare
fun {Q A B}
   Count = {NewCell 0}
   proc {Compute A B}
      if A=<B then
	 {Assign Count @Count+A}
	 {Compute A+1 B}
      end  
   end
in
   {Compute A B}
   @Count
end
{Browse {Q 1 3}}