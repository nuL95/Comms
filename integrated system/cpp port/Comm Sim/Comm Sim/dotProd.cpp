//Author: Mark Blair Date: 1/4/2025
//This finds the dot product between vec1 and vec2.
#include "SigLib.h"

double dotProd(const std::vector<double>& vec1, const std::vector<double>& vec2) {
	int vec1_len = vec1.size();
	int vec2_len = vec2.size();
	double sum = 0;
	if (vec1_len != vec2_len) { return -1; }
	for (int i = 0; i < vec1_len; i++) {
		sum += vec1[i] * vec2[i];
	}
	return sum;
}