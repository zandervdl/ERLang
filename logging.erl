-module(logging).
-export([start/0, entry/1, init/0]).

start() ->
    register(loging, spawn(?MODULE, init, [])).

entry(Data) -> 
    ets:insert(logbook, {{now(), self()},date(), time(), Data}).

init() ->
    ets:new(logbook, [named_table, ordered_set, public]),
    loop().

loop() -> 
    receive
	stop -> ok
    end.
	

%% observer:start(). to show logbook
%% logging:start(). to start logging 