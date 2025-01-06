#include "SigLib.h"

void vec_to_file(const std::vector<double>& vec, const std::string& filename) {
	std::ofstream outf{ filename };
	if (!outf) { std::cerr << "Couldn't open file."; }
	for (int i = 0; i < vec.size(); i++) {
		outf << vec[i] << "\n";
	}
}