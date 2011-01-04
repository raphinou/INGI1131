%WaitOr
declare X Y
proc {WaitOr X Y}
   T in
   thread {Wait X} T=unit end
   thread {Wait Y} T=unit end
   {Wait T}
end
thread {WaitOr X Y} {Browse hello} end


%WaitOrValue
% I don't think it's possible to stay in the declarative world
declare
X Y
fun {WaitOrValue X Y} R in
   thread {Wait X} try R=X catch _ then skip end  end
   thread {Wait Y} try R=Y catch _ then skip end  end
   R
end
{Browse x#X}
{Browse y#Y}
{Browse {WaitOrValue X Y}}
