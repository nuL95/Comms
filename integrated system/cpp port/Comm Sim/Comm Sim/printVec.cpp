//Author: Mark Blair Date: 1/4/2025
//This prints vec if it is smaller than some size to the console.
#include "SigLib.h"

void printVec(const std::vector<double>& vec) {
	if (vec.size() > 40) {
		std::cout << "yeah thats too big";
	}
	else {
		for (int i = 0; i < vec.size(); i++) {
			std::cout << vec[i] << "\n";
		}
	}
}