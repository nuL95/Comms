//Author: Mark Blair Date: 1/4/2025
//This upsamples a vector by upsample_factor
#include "SigLib.h"

std::vector<double> upsample(const std::vector<double> vec, int upsample_factor) {
	int vec_len = vec.size();
	std::vector<double> upsampled_vector(vec_len * upsample_factor);
	for (int i = 0; i < vec_len; i++) {
		upsampled_vector[i * upsample_factor] = vec[i];
	}
	return upsampled_vector;
}