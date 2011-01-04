%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
fun {NewQueue}
   X in
   q(0 X X)
end   
fun {Insert q(N S E) X}
   E1 in
   E=X|E1 q(N+1 S E1)
end
fun {Delete q(N S E) X}
   S1 in
   S=X|S1 q(N-1 S1 E)
end
fun {DeleteNonBlock q(N S E) X}
   if N>0 then H S1 in
      X=[H] S=H|S1 q(N-1 S1 E)
   else
      X=nil q(N S E)
   end
end
fun {DeleteAll q(_ S E) L}
   X in
   L=S E=nil
   q(0 X X)
end
fun {Size q(N _ _)} N end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Includes bug fix (see Errata page)
declare
proc {NewMonitor ?LockM ?WaitM ?NotifyM ?NotifyAllM}
   Q={NewCell {NewQueue}}
   Token1={NewCell unit}
   Token2={NewCell unit}
   CurThr={NewCell unit}
   % Returns true if got the lock, false if not (already inside)
   fun {GetLock}
      if {Thread.this}\=@CurThr then Old New in
	 {Exchange Token1 Old New}
	 {Wait Old}
	 Token2:=New
	 CurThr:={Thread.this}
	 true
      else false end
   end
   proc {ReleaseLock}
      CurThr:=unit
      unit=@Token2
   end
in
   proc {LockM P}
      if {GetLock} then
	 try {P} finally {ReleaseLock} end
      else {P} end
   end
   proc {WaitM}
   X in
      Q:={Insert @Q X}
      {ReleaseLock} {Wait X}
      if {GetLock} then skip end
   end
   proc {NotifyM}
   X in
      Q:={DeleteNonBlock @Q X}
      case X of [U] then U=unit else skip end
   end
   proc {NotifyAllM}
   L in
      Q:={DeleteAll @Q L}
      {ForAll L proc {$ X} X=unit end}
   end
end
%1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc {MakeMVar Put Get}
   C = {NewCell nil}
   {Browse @C}
   LockM WaitM NotifyM NotifyAllM
   {NewMonitor LockM WaitM NotifyM NotifyAllM}
in
   proc {Put V}
      {LockM proc {$}
		if @C\=nil then
		   {WaitM}
		   {Put V}
		else
		   C:=V
		   {Browse 'cell it now'#V}
		   {NotifyM}
		end
	     end
      }
   end
   proc {Get X}
      {LockM proc {$}
		if @C==nil then
		   {WaitM}
		   {Get X}
		else
		   {Exchange C X nil}
		   {Browse 'cell it now nil, read'#X}
		   {NotifyM}
		end
	     end
      }
   end
end
%MPut MGet X1 X2 X3
%{MakeMVar MPut MGet}
%{MPut a}
%{MPut b}
%{MPut c}
%{MGet _}
class MVar
   attr c mlock mwait mnotify mnotifyall
   meth init()
      MLock MWait MNotify MNotifyAll
   in
      c:={NewCell nil}
      {NewMonitor MLock MWait MNotify MNotifyAll}
      mlock:=MLock
      mwait:=MWait
      mnotify:=MNotify
      mnotifyall:=MNotifyAll
   end
   meth put(V)
      {@mlock proc {$}
		if @@c\=nil then
		   {@mwait}
		   {self put(V)}
		else
		   @c:=V
		   {Browse 'cell is now'#V}
		   {@mnotify}
		end
	     end
      }
   end
   meth get(X)
      {@mlock proc {$}
		if @@c==nil then
		   {@mwait}
		   {self get(X)}
		else
		   {Exchange @c X nil}
		   {Browse 'set to nil, read'#X}
		   {@mnotify}
		end
	     end
      }
   end
end
proc {MakeMVar2 MPut MGet}
   Mv = {New MVar init()}
in
   proc {MPut V}
      {Mv put(V)}
   end
   proc {MGet X}
      {Mv get(X)}
   end
end
MPut2
MGet2
{MakeMVar2 MPut2 MGet2}
{MPut2 s}
{MPut2 t}
{MGet2 _}




declare
Trans NewCellT
{NewTrans Trans NewCellT}
T={MakeTuple db 1000}
for I in 1..1000 do T.I={NewCellT I} end
fun {Rand} {OS.rand} mod 1000 + 1 end
proc {Mix}
   {Trans proc {$ Acc Ass Exc Abo }
	     I={Rand} J={Rand} K={Rand}
	     if I==J orelse I==K orelse J==K then {Abo} end
	     A={Acc T.I} B={Acc T.J} C={Acc T.K}
	  in
	     {Ass T.I A+B-C}
	     {Ass T.J A-B+C}
	     {Ass T.K  ~A+B+C}
	  end
   }
end
S={NewCellT 0}
fun {Sum}
   {Trans fun {$ Acc Ass Exc Abo}
	     {Ass S 0}
	     for I in 1..1000 do
		{Ass S {Acc S}+{Acc T.I}} end
	     {Acc S}
	  end _
   }
end
{Browse {Sum}} % Displays 500500
for I in 1..1000 do {Mix} end % Mixes up the elements
{Browse {Sum}} % Still displays 500500
