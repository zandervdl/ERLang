%% @author: Zander Van de Laer
%% @doc
%% A battery management system running as deamon
%% for raspberry pi
%% @end

-module(test).
-export([start/0, stop/0, loop/2]).

start() ->
	Outputs = init_out(),
	Inputs = init_in(),
	initialise(Outputs),
	
	Pid = spawn(test, loop, [Inputs, Outputs]),
	Pid.
	
stop() ->
	gpio:release(5),
	gpio:release(6),
	gpio:release(13),
	gpio:release(19),
	gpio:release(26),
	gpio:release(20),
	gpio:release(21),
	io:format("\ec"),
	io:fwrite("program terminated~n").
	
loop(Inputs, Outputs) ->	%%check if battery is oke
	case gpio:read(element(1, Inputs)) of
		"0" ->  gpio:write(element(4, Outputs), 0),     %output PowerOff
				logging:entry("BATTERY ERROR"),
				generator(Inputs, Outputs),
				charge(Inputs, Outputs);
		"1" ->  gpio:write(element(4, Outputs), 1),     %output PowerOn
				io:fwrite("battery OK~n"),
				timer:sleep(5000),
				generator(Inputs, Outputs),
				loop(Inputs, Outputs)
	end,
	receive
	stop ->
		gpio:release(Inputs),
		gpio:release(Outputs),
		io:format("\ec"),
		io:fwrite("program terminated~n"),
		ok
	end.
	
generator(Inputs, Outputs) ->	%%check if generator is oke
	case gpio:read(element(2, Inputs)) of
		"0" ->
			io:fwrite("Generator Error~n"),
			logging:entry("GENERATOR ERROR"),

			gpio:write(element(5, Outputs), 0),
			timer:sleep(1000),
			gpio:write(element(5, Outputs), 1),
			timer:sleep(1000),
			gpio:write(element(5, Outputs), 0),

			loop(Inputs, Outputs);
		"1" ->
			gpio:write(element(5, Outputs), 1)     %GeneratorIndication
	end.
	
charge(Inputs, Outputs)  ->	%%battery charging
	%Charge start
	gpio:write(element(4, Outputs), 0), %output PowerOff

	%LED animation
	io:fwrite("charging~n"),
	timer:sleep(500),
	gpio:write(element(1, Outputs), 1),
	timer:sleep(500),
	gpio:write(element(2, Outputs), 1),
	timer:sleep(500),
	gpio:write(element(3, Outputs), 1),
	timer:sleep(500),
	gpio:write(element(1, Outputs), 0),
	gpio:write(element(2, Outputs), 0),
	gpio:write(element(3, Outputs), 0),
	loop(Inputs, Outputs).



init_in() ->
	Check1 = gpio:init(21, in),     %BatteryCheck
	Check2 = gpio:init(20, in),     %GeneratorCheck
	{Check1, Check2}.

init_out() ->
	L0 = gpio:init(5, out),         %1
	L1 = gpio:init(6, out),         %2
	L2 = gpio:init(13, out),        %3
	B0 = gpio:init(26, out),        %4 BatteryPower
	G0 = gpio:init(19, out),        %5 GeneratorIndication
	{L0, L1, L2, B0, G0}.

initialise(Outputs) ->	%%set all outputs to 0
	gpio:write(element(1, Outputs), 0),
	gpio:write(element(2, Outputs), 0),
	gpio:write(element(3, Outputs), 0),
	gpio:write(element(4, Outputs), 0),
	gpio:write(element(5, Outputs), 0).