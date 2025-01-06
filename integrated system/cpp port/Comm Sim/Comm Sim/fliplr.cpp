//Author: Mark Blair Date: 1/4/2025
//This takes vec and flips the entries from left to right.
#include "SigLib.h"

std::vector<double> fliplr(const std::vector<double>& vec) {
	int vec_end = vec.size() - 1;
	std::vector<double> flipped_vec(vec.size());
	for (int i = 0; i < vec.size(); i++) {
		flipped_vec[i] = vec[vec_end - i];
	}
	return flipped_vec;
}