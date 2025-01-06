//Author: Mark Blair Date: 1/4/2025
//This element-wise multiplies vec1 and vec2.
#include "SigLib.h"

std::vector<double> eleWiseVecMult(const std::vector<double>& vec1, const std::vector<double>& vec2) {
	int vec1_len = vec1.size();
	int vec2_len = vec2.size();
	std::vector<double> error{ -1 };
	if (vec1_len != vec2_len) { return error; }
	std::vector<double> multVec(vec1_len);
	for (int i = 0; i < vec1_len; i++) {
		multVec[i] = vec1[i] * vec2[i];
	}
	return multVec;
}