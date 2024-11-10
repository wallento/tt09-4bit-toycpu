<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a 4 bit Toy CPU from a popular German textbook (Hoffmann, "Technische
Informatik", https://www.dirkwhoffmann.de/TI/). It is extremely simple and not
extremely useful but a useful CPU to transistion from digital design to
microprocessors in a fundamental way.

The CPU is based on a 4 bit accumulator. It has 4 bit instructions with 4 bit
operands. The memory is organized in 16 words of each 8 bit. The upper four bit
are the instruction, the lower 4 bit the operand. A `nop` instruction (or any
other instruction without operand) can be used for variables.

## How to test

The memory is outside the logic.

## External hardware

It requires a testbed to properly drive the pins.
