ECE241 PROJECT -  “SMART TRIALS” MEMORY GAME -  FINAL REPORT
 
 Introduction: Motivation and goals
 
Our inspiration for this project came from the classic memory type games you often see nowadays on smartphones.  A sequence of colors appears on the screen, then the user is prompted for input. If the user’s input matches the correct sequence they proceed to the next level, otherwise the game is over.
 
Our goals going into the project were as follows:
 
-       Create a system that creates, and remembers, a random binary pattern and shows it as colors on the VGA display
-       Collect user input, and compare it to the correct pattern
-       Based on the verdict of the comparison, notify the user whether they won or lost
-    Implement PS2 input (keyboard) to take away need for user to do binary conversions when inputting
-       BONUS GOAL: Create additional levels of difficulty including animation and audio
 
 
The Design
 
Inside the top module of our design, two main modules are instantiated; controlPath and dataPath. There are also some support modules that help datapath perform the required actions that were easier to implement when instantiated from the top module.

controlPath: This is the FSM for the design and controls all current state and next state logic. It has inputs from a variety of sources, mainly datapath, counters and the rate divider. It has outputs that drive most of the rest of the circuit.

dataPath: This module (or really collection of modules) implements the steps required during each state. It transforms the given inputs to the required outputs. It is made up of many separate modules which perform different functions, and are wired together.

pixelRateDivider: this module takes in CLOCK_50, and by counting clock cycles outputs logic 1 for exactly 1 clock cycle every X seconds a variety of settings (2s, 1.6s, 1.2s, 0.8s, 0.4s).

randomNumberGenerator: generates random numbers and transforms them into a sequence of 3 bits colours. Uses xor gates on bits of current output to produce the next output. This creates pseudo-random numbers. This subsystem is never reset so that each time it is run, a different number of clock cycles will pass, so you will never get the same sequence.

Below is a block diagrams of the entire design, then a close up of the inner workings of the random number generator system. The diagrams show how the module are connected, where they are instantiated from, and what data they transfer to each other.
