//Author: Mark Blair Date: 1/4/2025
//this convolves vec1 and vec2.
#include "SigLib.h"

std::vector<double> conv(const std::vector<double>& vec1, const std::vector<double>& vec2) {
	int vec1_len = vec1.size();
	int vec2_len = vec2.size();
	int conv_vec_len = vec1_len + vec2_len - 1;
	std::vector<double> conv_vec(conv_vec_len);
	for (int i = 0; i < conv_vec_len; ++i) {
		for (int j = 0; j < vec2_len; ++j) {
			if ((i - j) >= 0 && (i - j) < vec1_len) {
				conv_vec[i] += vec2[j] * vec1[i - j];
			}
		}
	}
	return conv_vec;
}