%1
% I don't think this is safe, as nothing makes the two operations on P atomic.
% In troducing a random delay, and calling it several times in different threads show it is nots afe
% What we need is to make these 2 operations act as one atomic operation, eg with a lock. An Echange with an unassigned variable works fine also
declare S P
proc {NewPort S P}
   P = {NewCell S}
end
proc {Send P Msg}
   NewTail
   L
in
      @P = Msg|NewTail
      P := NewTail
end
P={NewPort S}
{Browse S}
for I in 1..10 do
   thread {Delay {OS.rand} mod 500} {Send P msg#I} end
end


declare S P
proc {NewPort S P}
   P = {NewCell S}
end
proc {Send P Msg}
   NewTail
   L
in
   {Exchange P Msg|NewTail NewTail}
end
P={NewPort S}
{Browse S}
for I in 1..10 do
   thread {Delay {OS.rand} mod 500}{Send P msg#I} end
end

%2
% version given because addition waits for X to be bound.
% Here is a version that works, but that does not make both operation as one atomic operation.
declare
C={NewCell 0}
fun {Increment C}
   X in 
   X = @C
   C:= X+1 
end
{Browse {Increment C}}
{Browse @C}

% Here is a version that works with Exchange:
declare
C={NewCell 0}
for I in 1..1000 do 
   thread local X X2 in {Delay {OS.rand} mod 1000} {Exchange C X X2} X2=X+1 end end
end
{Browse @C}

% We could protect the critical region, eg with a lock
% We can also Exchange the value of the lock with an unbound variable to which we assign later.
declare
C={NewCell 0}
fun {Increment C}
   Old New in
%   Separating both operation would need a lock.
%   X = @C
%   C:= X+1
   {Exchange C Old New}
   {Delay {OS.rand} mod 1000} % this is also efficient because all delays here append in parallel!
   New=Old+1
   Old
end
for I in 1..10 do
   thread {Browse {Increment C}} end
end

%3
declare A1 A2 A3 A4 R
class BankAccount
   attr C
   meth init
      @C={NewCell 0}    
   end
   meth deposit(Amount)
      Old New in 
      {Exchange @C Old New}
      New=Old+Amount
   end
   meth withdraw(Amount)
      Old New in 
      {Exchange @C Old New}
      New=Old-Amount
   end
   meth getBalance($)
      @@C
   end
end
A1={New BankAccount init }
A2={New BankAccount init }
A3={New BankAccount init }
A4={New BankAccount init }
%for I in 1..1000 do
%   thread {Delay {OS.rand} mod 100} {A1 deposit(I)} end
%end
%{Browse expected#(1000*1001 div 2)}
%{Browse please_wait}
%{Delay 2000}
%{Browse {A1 getBalance($)}}
{A1 deposit(1000)}
{A2 deposit(1000)}
{A3 deposit(1000)}
{A4 deposit(1000)}
{Browse {A1 getBalance($)}+{A2 getBalance($)}+{A3 getBalance($)}+{A4 getBalance($)}}
R = accounts(1:A1 2:A2 3:A3 4:A4)
Lock = {NewLock}
proc {Transfer Source Dest Amount}
   %without the lock, balance can become negative despite the check!
   lock Lock then
      if {Source getBalance($)}>0 andthen Amount<{Source getBalance($)} then
	 {Browse Amount#fromaccount#Source#to#Dest}
	 {Source  withdraw(Amount)}
	 {Dest  deposit(Amount)}
      end
   end
end
for I in 1..1000 do
   thread
      Source={OS.rand} mod 4 +1
      Dest= {OS.rand} mod 4 +1
      Amount = {OS.rand} mod 1000
   in
      {Delay {OS.rand} mod 300} {Transfer R.Source R.Dest Amount}
   end
end
{Delay 4000}
{Browse {A1 getBalance($)}#{A2 getBalance($)}#{A3 getBalance($)}#{A4 getBalance($)}}
{Browse {A1 getBalance($)}+{A2 getBalance($)}+{A3 getBalance($)}+{A4 getBalance($)}}


%5 need to look at it.....
% I don't think the second one is correct. It has several problems:
- Both functions modify N 
- both put back in the cell the old value of the end of the queue they don't manipulate. But what if a concurrent thread modifies this end at the same time? We erase its change!
