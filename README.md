# ERLang project
## what is it?
it is a battery management system which checks if a battery is present and working. The program also checks if a powergenerator is present and working.
- When the battery is working it will print **battery OK** in the shell.
- When the battery is not functional or needs te be charged it will print a **charging...** animation in the shell.
- When power generator is not functional an **generator error** is printed in the shell.
- al event also have LED indication.

the gpio.erl is a wonderful erlang implementation of a module for Raspberry Pi's General Purpose Input/Output (GPIO) created by Paolo Oliveira <paolo@fisica.ufc.br>

the *test* and *energySys* are basically the same program, only difference is that *test* runs as a daemon.
calling **test:start().** will start the program, **test:stop().** will stop it.

*logging.erl* is a logging pogram. this way events will be logged and can be seen in the observer. don't forget to start the logger with **logging:start().**

