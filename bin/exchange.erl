-module(exchange). 
-export([start/0]).
-import(calling,[call_users/2]).  
start() ->
	{_,Users}=file:consult("calls.txt"),
	io:fwrite("** Calls to be made **~n"),
	start_users(Users),
	receive_messages()
	.
receive_messages()-> 
	receive
	{intro_master,Users,User,Timestamp}->
		io:fwrite("~w received intro message from ~w [~w] ~n",[Users,User,Timestamp]),
		receive_messages();
	{reply_master,Users,User,Timestamp}->
	    io:fwrite("~w received reply message from ~w [~w] ~n",[Users,User,Timestamp]),
		receive_messages()
	after 1500->
		io:fwrite("master has received no replies for 1.5 seconds, ending...~n")
		end
	.
start_users([])-> register(master,self());
start_users([User|Tail])->
	{Name,Calls} = User,
	io:fwrite("~s: ~w~n",[Name,Calls]),
	Pid =spawn(calling,call_users,[Calls,Name]),
	register(Name,Pid),
	start_users(Tail)
	.	