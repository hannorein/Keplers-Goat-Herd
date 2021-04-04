#!/bin/bash

echo "Running tests with: -O3 -ffast-math (used in paper)"
g++ -o kepler keplers_goat_herd.cpp -std=c++17 -ffast-math -Wall -O3 
./kepler
echo -e "\n\n"

echo "Running tests with: -O3 -ffast-math -march-native "
g++ -o kepler keplers_goat_herd.cpp -std=c++17 -ffast-math -Wall -O3 -march=native
./kepler
echo -e "\n\n"

echo "Running tests with: -O3 -march-native"
g++ -o kepler keplers_goat_herd.cpp -std=c++17 -Wall -O3 -march=native
./kepler
echo -e "\n\n"

echo "Running tests with: -O1"
g++ -o kepler keplers_goat_herd.cpp -std=c++17 -Wall -O1
./kepler
echo -e "\n\n"
