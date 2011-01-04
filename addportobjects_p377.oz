declare
fun {FoldL S Init Fun}
   case S of X|Xr then NewState in
      NewState={Fun X Init}
      {FoldL Xr NewState Fun}
   end
end
fun {NewPortObject Init Fun}
   S R in
   thread R={FoldL S Init Fun}end
   {NewPort S}
end
proc {NewPortObjects AddProc SendM}
   S  MsgFun P
   in
   fun {MsgFun Msg Procs}
      case Msg of add(Id Proc) then
	  {AdjoinAt Procs Id Proc}
      [] call(Id M) then
	 {Procs.Id M}
	 Procs
      else
	 Procs
      end
   end
   P={NewPortObject procs MsgFun}
   AddProc= proc {$ Id Proc} {Send P add(Id Proc)} end
   SendM = proc {$ Id M} {Send P call(Id M)} end
end
P1= proc {$ M} {Browse from_p1#M} end
P2=proc{$ M} {Browse from_p2#M} end
AddP SendM
{NewPortObjects AddP SendM}
{AddP p1 P1}
{AddP p2 P2}
{SendM p1 m1#to_p1}
{SendM p2 m1#to_p2}