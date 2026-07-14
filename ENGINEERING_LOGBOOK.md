# FFT Accelerator Engineering Logbook

Author : Shreenidhi Inamadar

============================================================
Day 1 : Project Initialization
============================================================

Date :
------------------------------------------------------------

Objective
---------
Set up the project repository and development environment before RTL development.

Tasks Completed
---------------

✓ Created Git repository

✓ Created project directory structure

    rtl/
    tb/
    docs/
    reports/
    synthesis/
    scripts/
    constraints/
    matlab/
    sim/
    uvm/

✓ Created README.md

✓ Created ENGINEERING_LOGBOOK.md

✓ Added .gitkeep files

✓ Created first Git commit

Git Commit
----------

Initial Project Setup

Concepts Learned
----------------

• Git tracks files, not empty folders.

• Empty folders require a .gitkeep file.

• Every project should start with a clean folder structure.

• Version control should be used from Day 1.

Industry Practices Learned
--------------------------

• Use meaningful commit messages.

• Keep documentation inside the repository.

• Organize RTL, Verification and Reports separately.

• Every milestone should have its own commit.

Problems Faced
--------------

Problem:
Git showed "Nothing to commit"

Reason:
Only empty folders existed.

Solution:
Created README.md and .gitkeep files.

Problem:
Git Author Identity Unknown

Reason:
Username and email were not configured.

Solution:

git config --global user.name
git config --global user.email

Deliverables
------------

✓ Git Repository

✓ Folder Structure

✓ README

✓ Engineering Logbook

Next Goal
---------

Begin RTL development of Complex Adder.

============================================================
Day 2 : Complex Adder RTL Development
============================================================

Objective
---------
Design and verify the first reusable RTL IP block.

Topics Learned
--------------

RTL Concepts

✓ RTL = Register Transfer Level

✓ Hardware vs Software thinking

✓ Parallel hardware

✓ Combinational Logic

✓ Module

✓ Ports

✓ logic

✓ signed

✓ parameter

✓ assign

Verification Concepts

✓ Testbench

✓ DUT

✓ initial block

✓ Simulation

✓ Self-checking verification

✓ $display

✓ #delay

✓ $finish

Design Decisions
----------------

• Complex Adder is purely combinational.

• No clock required.

• No reset required.

• Uses assign instead of always_comb because each output is a single combinational equation.

• Parameterized width for reusability.

Modules Created
---------------

complex_adder.sv

complex_adder_tb.sv (Work in Progress)

Verification Progress
---------------------

Completed

✓ Directed testcase framework

✓ PASS/FAIL checking

Pending

□ Task automatic

□ Directed testcase library

□ Coverage

□ Assertions

□ Random Testing

□ UVM

Interview Concepts Learned
--------------------------

Q. Why doesn't the Complex Adder have a clock?

A.
It is a purely combinational module.
No internal state or registers exist.

------------------------------------

Q. Why use assign?

A.

Each output depends on a single combinational equation.
assign produces cleaner RTL.

------------------------------------

Q. Why logic instead of reg?

A.

SystemVerilog introduced logic to replace reg in most RTL.
logic avoids confusion and can be driven from procedural or continuous assignments (with appropriate single-driver usage).

------------------------------------

Q. What hardware is synthesized?

A.

Two independent adders.

One computes

P_real

One computes

P_imag

Both operate simultaneously.

Problems Faced
--------------

• Confused packed and unpacked arrays.

• Incorrectly used input/output inside testbench.

• Forgot $ in $display.

Lessons Learned
---------------

Hardware is described, not programmed.

Verification is equally important as RTL.

Git Commit
----------

Pending after verification completion.

Next Goal
---------

Complete professional verification of Complex Adder using

• task automatic

• 10+ directed tests

• Functional Coverage

• Assertions

• Random Verification

• Mini-UVM