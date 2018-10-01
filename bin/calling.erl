-module(calling). 
-export([call_users/2]).

call_p(Users)->
	receive
	{intro,User}->
	timer:sleep(random:uniform(100)),
	Pid = whereis(User),
	if
	Pid == undefined ->
	    ok;
    true ->
		Pid ! {reply,Users}	
	end,
	Pid_Master = whereis(master),
	if
	Pid_Master == undefined ->
	    ok;
	true ->
    Pid_Master ! {intro_master,Users,User,get_timestamp()}
    end, 	
	call_p(Users);
	{reply,User}->
	Pid_Master = whereis(master),
	if
	Pid_Master == undefined ->
	    ok;
    true ->
    Pid_Master !{reply_master,Users,User,get_timestamp()}
	end,
	call_p(Users)
	after 1000 ->
	io:fwrite("~s has received no calls for 1 second ,  ending....~n",[Users])	
	end
	.
get_timestamp() ->
    {Mega,Second,Micro}=now(),
	(Mega*1000000+Second)*1000+Micro.
call_users([],Self)->call_p(Self);
call_users([User|Tail],Self)->
    timer:sleep(rand:uniform(100)),
	Pid = 	whereis(User),
	if 
	Pid == undefined ->
		ok;
	true ->  
	Pid ! {intro,Self}
	end,
	call_users(Tail,Self)
	.