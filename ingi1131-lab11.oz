% port object construction
declare
fun {NewPortObject  Behaviour Init}
   S P
   proc {MsgLoop S State}
      case S of  Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end   
in
   thread {MsgLoop S Init} end
   P={NewPort S}
end
fun {CellBehaviour Msg State}
   case Msg of access(X) then
      X=State
      State
   [] assign(V) then
      V
   end
end
proc {Assign C V}
   {Send C assign(V)}
end
fun {Access C}
   V in
   {Send C access(V)}
   V
end
fun {NewPCell Value}
   {NewPortObject CellBehaviour Value}
end
C
C={NewPCell 0}
{Browse {Access C}}
{Assign C 5}
{Assign C 6}


%3
declare
fun {NewCPort S}
   {NewCell S}
end
proc {SendC P Msg}
   T V in
   %Msg|T=@P
   %P:=T
   %Exchange is better because one operation
   {Exchange P Msg|T T}
end
S
{Browse S}
P={NewCPort S}
{SendC P 8}

%4
declare
proc {NewPortClose S ?SendC ?CloseC}
   P in
   proc {SendC Msg}
      T in
      %Will fail due to unification with nil
      {Exchange P Msg|T T}
   end
   proc {CloseC}
      @P=nil
   end
   P={NewCell S}
end
S P MySend MyClose
{NewPortClose S MySend MyClose}
{Browse S}
{MySend 5}
{MyClose}
{MySend t}


%5
declare
fun {Q A B}
   Cell={NewCell 0}
in
   for I in A..B do
      New Old
   in
      {Exchange Cell Old New}
      New=Old+I %no wait on old needed as it implicitely will wiat for old in the addition
   end
   @Cell
end
V={Q 1 9}
{Browse V}

{Browse {Q 1 5}}

%6
%a
declare
class Counter
   attr c
   meth init()
      c:=0
   end
   meth add(I)
      Old New in
      c:=@c+I
   end
   meth read(R)
      R=@c
   end
end
fun {Q A B}
   R 
   MyCounter={New Counter init()}
   in
   for I in A..B do
      {MyCounter add(I)}
   end
   {MyCounter read(R)}
   R
end
{Browse {Q 1 5}}
%b
declare
class Port
   % attribute c is not a cell, so we initialize it with a new cell
   attr c
   meth init()
      S in
      {Browse S}
      c:={NewCell S}
   end
   meth send(M)
      T
   in
      {Exchange @c M|T T}
   end
end
fun {NewClassPort}
   {New Port init()}
end
proc {SendClass P V}
   {P send(V)}
end
P
P={NewClassPort}
%{SendClass P 5}
%c
class PortClose from Port
   meth close()
      @@c=nil
   end
end
fun {NewClassPortClose}
   {New PortClose init()}
end
proc {CloseClassPort P}
   {P close()}
end
proc {SendClassPort P M}
   {P send(M)}
end
P2
P2={NewClassPortClose}
{SendClassPort P2 7}
{CloseClassPort P2}
   
		   
		   
