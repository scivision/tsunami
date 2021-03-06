# tsunami

[![Build Status](https://travis-ci.org/modern-fortran/tsunami.svg?branch=master)](https://travis-ci.org/modern-fortran/tsunami)
[![Build status](https://ci.appveyor.com/api/projects/status/ttcpllua2iqdv937?svg=true)](https://ci.appveyor.com/project/scivision/tsunami)
[![GitHub issues](https://img.shields.io/github/issues/modern-fortran/tsunami.svg)](https://github.com/modern-fortran/tsunami/issues)

A shallow water equations solver. Companion running example 
for [Modern Fortran: Building Efficient Parallel Applications](https://www.manning.com/books/modern-fortran?a_aid=modernfortran&a_bid=2dc4d442).

## Getting the code

To run the model on your local machine, get the code using git:

```
git clone https://github.com/modern-fortran/tsunami
```

### Switching between different tags

The code is organized in tags so you can easily go back and forth 
different stages of the app as it is taught in the book.
For example, below command will take you to the tag `3b`:

```
git checkout 3b
```

## Building the model

### System dependencies

On Debian-based systems:

```
sudo apt install gfortran cmake make
```

On Redhat-based systems:

```
sudo yum install gfortran cmake make
```

or

```
sudo dnf install gfortran cmake make
```

### Building OpenCoarrays

To build OpenCoarrays, follow the instruction in Appendix A of the book.
OpenCoarrays are required to build the parallel version of the model.

### Building tsunami

```
mkdir build
cd build
FC=caf cmake ..
make
```

The executable will be built in the `build/bin` directory.

## Running the model

From the `build` directory, type:

```
bin/app
```

If working with the parallel code, type:

```
cafrun -n 2 bin/app
```

to run on 2 images, for example.
Change this number if you want to use more images.

## Plotting the results

All the plotting code is located in the `plotting` directory.
You will need a Python build (either 2.7 or 3.x is fine) 
with numpy and matplotlib packages installed.

If you're setting up Python from scratch, I recommend using Python 3
and creating a dedicated virtual environment. 
For example, in `tsunami/plotting` directory:

```
python3 -m venv venv            # create new python env
source venv/bin/activate        # activate python env
pip install -U pip              # upgrade installer
pip install -r requirements.txt # install dependencies
```
