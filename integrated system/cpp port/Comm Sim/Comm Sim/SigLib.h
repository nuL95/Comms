//Author: Mark Blair Date: 1/4/2025
#pragma once
#include <vector>
#include <stdio.h>
#include <math.h>
#include <iostream>
#include <random>
#include <fstream>
# define M_PI          3.141592653589793238462643383279502884L /* pi */

//This takes vec and flips the entries from left to right.
std::vector<double> fliplr(const std::vector<double>& vec);

//this convolves vec1 and vec2.
std::vector<double> conv(const std::vector<double>& vec1, const std::vector<double>& vec2);

//This prints vec if it is smaller than some size to the console.
void printVec(const std::vector<double>& vec);

//This finds the dot product between vec1 and vec2.
double dotProd(const std::vector<double>& vec1, const std::vector<double>& vec2);

//This element-wise multiplies vec1 and vec2.
std::vector<double> eleWiseVecMult(const std::vector<double>& vec1, const std::vector<double>& vec2);

//This upsamples a vector by upsample_factor
std::vector<double> upsample(const std::vector<double> vec, int upsample_factor);

//writes vec to filename
void vec_to_file(const std::vector<double>& vec, const std::string& filename);