@echo off
REM Compile the design + testbench, then run the simulation
iverilog -g2005 -Wall -o sim.out rtl/traffic_light.v tb/traffic_light_tb.v
if errorlevel 1 exit /b 1
vvp sim.out