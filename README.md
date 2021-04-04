# Some more experiments

**Added by Hanno Rein, April 4th 2021 (Update):**

Another small update:

- By using a 4th order initial condition (requiring one sin(), cos() and sqrt() operation). The Newton-Raphson method converges in 1 step for the test problem. This makes it faster than the contour method when building with "-march-native".

- This also has the advantage that it can automatically stop the iteration when converged. For this test case, this is not important (it always uses one step).

**Added by Hanno Rein, April 4th 2021:**

I was intrigued by the speed up offered by the contour method, so I did some more experiments. Here are some notes on what I found.

- Compiler options have a huge effect. For example, adding the compiler option "-march=native" makes the series estimate significantly faster on my machine. In fact, with this compiler option it makes the series estimate about 2x faster than the contour method! Admittedly at a lower accuracy (I've used the same test problem as in the paper, requiring an accuracy of 1e-12. Changing the accuracy requirement could reestablish the contour method as the winner). 

- The "-ffast-math" compiler option also has a huge effect. Using it might lead to biased floating point rounding and make the code machine dependent. Whether one cares about that depends on the application. It would matter a lot for long term orbit integrations.

- By using a slightly better initial estimate for the Newton-Raphson algorithm (second order in e, requiring one sin() evaluation), one can avoid 1 of the 3 iterations required for the standard test problem described in the paper. One can also slightly optimize the operations in the iteration step. The improved method is labeled  Newton-Raphson-Hanno in this repository. As a result the contour method is now only ~1.2 - 1.5x (depending on compiler options) faster than Newton-Raphson. 

- All of the tests obviously depend on eccentricity (the standard test uses e=0.1). If the eccentricity is very high, a higher order initial estimate does better for the iterative methods. Furthermore, for very eccentric orbits, the results depend on the sample points. The original test uses a uniform grid in eccentric anomaly. I think a uniform grid in mean anomaly might be a fairer comparison, at least for N-body applications.

- The standard test in the paper calculates the mean absolute error. Again, this might depend on the application, but one might prefer a maximum error if one wants to ensure a given accuracy. This again can change the measured speedup slightly. 

- At the moment, the standard test first make sure that the number of points/iterations is high enough for the required accuracy. Once the number of points/iterations has been determined, then the performance is measured. But when using an iterative method, one can relatively easily monitor convergence during the iteration itself. That might be an important advantages because one can just do one more iteration (rather starting from scratch) if the accuracy is not good enough. I suspect something similar could be done for the contour method, but I'm not sure how.

- I did not attempt to speed up the contour method.

- Below is the output of the various tests including the improved iterative method (labelled Newton-Raphson-Hanno) and various compiler options. All tests use the standard setup described in the paper. 

- In summary: The contour algorithm is indeed very fast, just maybe not 2x faster than standard methods. However, it can still easily compete with the these methods which is impressive given it is such a different approach. Whether it is the fastest method in the end depends on the application, compiler options, etc. 


```
Running tests with: -O3 -ffast-math (used in paper)
N_ell = 1000000
e = 0.10
tolerance = 1.00e-12
Computed Newton-Raphson estimate in 3 steps after 139.8 ms with mean-error 2.11e-17
Computed Newton-Raphson-Hanno estimate in 2 steps after 105.7 ms with mean-error 1.20e-14
Computed Danby estimate in 2 steps after 140.1 ms with mean-error 2.12e-17
Computed series estimate in 11 steps after 84.8 ms with mean-error 4.74e-13
Computed contour estimate in 5 steps after 69.7 ms with mean-error 2.17e-16



Running tests with: -O3 -ffast-math -march-native
N_ell = 1000000
e = 0.10
tolerance = 1.00e-12
Computed Newton-Raphson estimate in 3 steps after 136.2 ms with mean-error 1.98e-17
Computed Newton-Raphson-Hanno estimate in 2 steps after 101.7 ms with mean-error 1.20e-14
Computed Danby estimate in 2 steps after 133.0 ms with mean-error 1.99e-17
Computed series estimate in 11 steps after 30.5 ms with mean-error 4.74e-13
Computed contour estimate in 5 steps after 80.4 ms with mean-error 2.17e-16



Running tests with: -O3 -march-native
N_ell = 1000000
e = 0.10
tolerance = 1.00e-12
Computed Newton-Raphson estimate in 3 steps after 138.6 ms with mean-error 1.22e-16
Computed Newton-Raphson-Hanno estimate in 2 steps after 101.6 ms with mean-error 1.20e-14
Computed Danby estimate in 2 steps after 146.7 ms with mean-error 1.26e-16
Computed series estimate in 11 steps after 213.1 ms with mean-error 4.74e-13
Computed contour estimate in 5 steps after 78.3 ms with mean-error 1.96e-16



Running tests with: -O1
N_ell = 1000000
e = 0.10
tolerance = 1.00e-12
Computed Newton-Raphson estimate in 3 steps after 147.5 ms with mean-error 1.22e-16
Computed Newton-Raphson-Hanno estimate in 2 steps after 111.7 ms with mean-error 1.20e-14
Computed Danby estimate in 2 steps after 153.3 ms with mean-error 1.26e-16
Computed series estimate in 11 steps after 219.6 ms with mean-error 4.74e-13
Computed contour estimate in 5 steps after 77.3 ms with mean-error 1.96e-16
```





# Kepler's Goat Herd

C++ code for solving Kepler's equation using contour integration, following Philcox et al. (2021, [arXiv](https://arxiv.org/abs/2103.15829)). This uses a method originally proposed by Ullisch (2020) to solve the "geometric goat problem".

The code contains implementations of a variety of solution methods:
- Newton-Raphson: The quadratic Newton-Raphson root finder.
- Danby: The quartic root finder described in Danby (1988).
- Series: An elliptical series method, as described in Murray & Dermott.
- Contour: A new method based on contour integration.

Given an array of mean anomalies, an eccentricity and a desired precision, the code will estimate the eccentricity using each method. The accuracy of each approach is increased until the desired precision is reached, relative to an (overconverged) Danby estimate with 100 steps, and timing is performed using the C++ `chrono` package.

To compile the code using g++, simply run ```g++ -o kepler keplers_goat_herd.cpp -std=c++17 -ffast-math -Wall -O3```.  The code can be run using ```./kepler```. The individual functions, e.g. ```compute_contour``` can also be used outside of this script, given an input array of mean anomalies and an eccentricity.

**Authors**:
- Oliver Philcox (Princeton, [ohep2@cantab.ac.uk](mailto:ohep2@cantab.ac.uk))
