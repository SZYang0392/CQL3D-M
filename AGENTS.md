# Repository Guidelines

## Project Structure & Module Organization
CQL3D is primarily fixed-form Fortran at the repository root. The main driver is `a_cqlp.f`; subsystem files use prefixes such as `td*` (time advance/transport), `urf*` (RF), `eq*` (equilibrium), and `plt*` (plot/output). Shared declarations are in `*.h` include files (for example, `param.h`, `comm.h`).

Build variants are kept as root-level `makefile*` files, with historical platform copies in `make_archive/`. MPI preprocessing helpers are in `mpi/`. Regression scripts and inputs are in `00_Cql3d_Regression_Tests/`. Large auxiliary datasets are under `adas_dir/` and `ADPAK_data/`.

## Official Documentation
- `cqlinput_help`: Official reference for CQL3D input-file fields and options. Use this first when adding or changing `cqlinput` parameters.
- `cql3d_manual.pdf`: Official user/theory manual for model assumptions, run setup, and output interpretation.

## Build, Test, and Development Commands
- `make -f makefile_gfortran64.CentOS7.1`: Build serial executable `xcql3d_gfortran64.1`.
- `make -f makefile_mpi.gfortran64`: Build MPI executable `xcql3d_mpi.gfortran64` (uses `mpi/doparallel.py`).
- `make -f makefile_gfortran64.CentOS7.1 clean`: Remove serial build artifacts.
- `make -f makefile_mpi.gfortran64 clean`: Remove MPI build artifacts and `*_mpitmp.f`.
- `mpirun -np 4 ./xcql3d_mpi.gfortran64 > log_mpi`: Example MPI run.
- `cd 00_Cql3d_Regression_Tests && bash ./tests.sh`: Run packaged regression tests (set `XCQL3D` in `tests.sh` first).

Runtime namelist input must be named `cqlinput` in the run directory.

## Coding Style & Naming Conventions
Preserve existing fixed-form Fortran formatting (alignment, continuation style, and include usage). Follow current lowercase file naming and subsystem prefixes for new routines. Reuse existing common blocks/header declarations instead of duplicating constants across files.

Keep changes compatible with the current `real*8` workflow (see gfortran makefiles using default-real-8 options).

## Testing Guidelines
For numerical or physics changes, run at least one focused case and relevant regression cases from `00_Cql3d_Regression_Tests/`. Keep per-case logs such as `log_test*`, and compare key outputs (`*.nc`, `*.ps`, diagnostic text) with provided baselines (for example `test_results_201026.zip`). Record the exact `cqlinput_*` file used.

## Commit & Pull Request Guidelines
History shows both short imperative subjects and explicit version-tag commits (for example, `version="cql3d_git_210125.1"`). Prefer concise, scoped commit subjects that name the affected physics area or subsystem.

PRs should include: purpose, affected modules, makefile/build target used, regression evidence (tests run and notable output deltas), and links to related issues or change notes (for example in `a_change.h`).
