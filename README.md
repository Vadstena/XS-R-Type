# XS-R-Type

Minimalist version of [R-Type](https://en.wikipedia.org/wiki/R-Type) written in Assembly. In this version, the object of the game is simply to survive for as long as possible while collecting as many points as possible. The game ends when the spacecraft collides with either an asteroid, `*`, or a black hole, `O`. Points are awarded for destroying asteroids. A single laser beam destroys an asteroid, but will also evaporate when the two collide. Black holes absorb all laser beams they come across and therefore cannot be destroyed. Maneuver your spacecraft accordingly!

https://github.com/user-attachments/assets/f1b04776-744d-4222-a3c1-b530c06138b1

## Description

The games is written in P3 Assembly. P3 is a 16-bit CPU used in my Introduction to Computer Architecture course, which comes in a board (based on [DIO5](https://digilent.com/reference/_media/dio5/dio5_rm.pdf)) with a handful of integrated components. The 7 segment display is used to show the accumulated points (# of destroyed asteroids), the LEDs change configuration when an asteroid is destroyed (the same seemingly random values used to generate asteroid and black hole spawn coordinates are reused and fed to the LEDs, producing seemingly random configurations), and the following buttons enable gameplay:

`IE` (re)starts the game.
`I0`, `I1`, `I2` and `I3` move the spacecraft *down*, *up*, *left* and *right*, respectively.
`I4` fires the laser cannon.

While the game is far more visually appealing when played on the real thing, chances are, like me, you don’t own this board. Luckily there are a couple of P3 simulators out there. The simplest way to play this game is to copy its [source code](xs_r_type.as) and paste it in [this](https://p3js.goncalomb.com/) fantastic web simulator a fellow student [developed](https://github.com/goncalomb/p3js). Click `* New` (on the right) -> paste the game's source code -> `Assemble and Run` -> Tick `Show Control Unit` -> Tick `Show I/O` -> Ready to play. The rest of this guide covers how to run it locally.

## Getting Started

### Dependencies

* Java 7 through 11 (at least)

### Executing the program

Assemble the game
```
./p3as xs_r_type.as
```
Then, run the graphical simulator
```
java -jar p3sim.jar
```

Once in the simulator, import the assembled executable (`Ficheiro` -> `Carrega Programa` -> select the `.exe`), click `Run` (`Corre`), and open the `board` and `terminal` windows (`Ver` -> `Janela Texto` and `Ver` -> `Janela Placa`). A small video demo of the process:

https://github.com/user-attachments/assets/ae5cb308-aa7a-4096-af72-93fdd8c63e04

## Authors

Joao Silva

[p3as](p3as) and [p3sim.jar](p3sim.jar) were provided by the teachers.
