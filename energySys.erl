%% batery system
%% @end

-module(energySys).
-export([main/0]).

main() ->
	Outputs = init_out(),
	Inputs = init_in(),
	start(Outputs),

	battery(Outputs, Inputs).


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

start(Outputs) ->
	gpio:write(element(1, Outputs), 0),
	gpio:write(element(2, Outputs), 0),
	gpio:write(element(3, Outputs), 0),
	gpio:write(element(4, Outputs), 0),
	gpio:write(element(5, Outputs), 0).

charge(Outputs, Inputs)  ->
	%ChargeStart
	gpio:write(element(4, Outputs), 0), %PowerOff

	%LED animation
	io:format("\ec"),
	io:fwrite("charging"),
	timer:sleep(500),
	gpio:write(element(1, Outputs), 1),
	io:fwrite("."),
	timer:sleep(500),
	gpio:write(element(2, Outputs), 1),
	io:fwrite("."),
	timer:sleep(500),
	gpio:write(element(3, Outputs), 1),
	io:fwrite("."),
	timer:sleep(500),
	gpio:write(element(1, Outputs), 0),
	gpio:write(element(2, Outputs), 0),
	gpio:write(element(3, Outputs), 0),
	io:fwrite("~n"),
	battery(Outputs, Inputs).

battery(Outputs, Inputs) ->
	case gpio:read(element(1, Inputs)) of
		"0" ->  gpio:write(element(4, Outputs), 0),     %PowerOff
				generator(Outputs, Inputs),
				charge(Outputs, Inputs);
		"1" ->  gpio:write(element(4, Outputs), 1),     %PowerOn
				io:format("\ec"),
				io:fwrite("battery OK~n"),
				timer:sleep(5000),
				generator(Outputs, Inputs),
				battery(Outputs, Inputs)
	end.

generator(Outputs, Inputs) ->
	case gpio:read(element(2, Inputs)) of
		"0" ->
			io:format("\ec"),
			io:fwrite("Generator Error~n"),

			gpio:write(element(5, Outputs), 0),
			timer:sleep(1000),
			gpio:write(element(5, Outputs), 1),
			timer:sleep(1000),
			gpio:write(element(5, Outputs), 0),

			battery(Outputs, Inputs);
		"1" ->
			gpio:write(element(5, Outputs), 1)     %GeneratorIndication
	end.