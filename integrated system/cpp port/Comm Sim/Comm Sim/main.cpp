/*
Author: Mark Blair
Date: 1/4/2025
This project is a port of a matlab project, with the goal being to reproduce the results while getting more practice with c++ as it has been a while since I've used this language
*/
#include "SigLib.h"

int main() {
	int fc = 80000; //carrier frequency
	int fs = 500000; //sampling rate
	int N = 1000; //number of symbols
	int sps = 6; //samples per symbol of pulse shaping filter
	int span = 6; //symbol span of pulse shaping filter
	double bitPow = 1.0; // this is inherent to the bipolar communication where the symbols are 1 and -1
	double SNRdb = 40;
	double noisePow = bitPow / (pow(10.0, SNRdb / 10.0));
	//Eventually I'd like to read this stuff from a file, but I want to focus on signal processing right now.
	std::vector<double> channel = { 0.05, 0.7, 0.1, 0.02, 0.1, 0.09 };
	std::vector<double> nyq_fil = { -0.0065, -0.0087, -0.0054, 0.0035, 0.0149, 0.0232, 0.0223, 0.0086, -0.0170, -0.0472, -0.0696, -0.0703, -0.0380, 0.0310, 0.1306, 0.2446, 0.3507, 0.4258, 0.4530, 0.4258,
		0.3507, 0.2446, 0.1306, 0.0310, -0.0380, -0.0703, -0.0696, -0.0472, -0.0170, 0.0086, 0.0223, 0.0232, 0.0149, 0.0035, -0.0054, -0.0087, -0.0065 };
	//Lazy way of giving the nyquist filter has a one sample delay
	std::vector<double> delayed_nyq_fil = nyq_fil;
	delayed_nyq_fil.pop_back();
	std::vector<double>::iterator it;
	it = delayed_nyq_fil.begin();
	it = delayed_nyq_fil.insert(it, 0);
	//Random Stuff
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> generate_bit(0, 1);
	std::uniform_real_distribution<double> generate_phi_off(-1.5, 1.5);
	std::uniform_real_distribution<double> generate_f_off(-2, 2);
	std::normal_distribution<> generate_noise(0, sqrt(noisePow));
	double phi = generate_phi_off(gen); //phase offset of transmit carrier
	double f0 = generate_f_off(gen); //frequency offset of transmit carrier
	//Generate N random bits, then turn them into PAM2 AKA bipolar modulation
	std::vector<int> bitStream(N);
	std::vector<double> syms(N);
	for (int i = 0; i < N; i++) {
		bitStream[i] = generate_bit(gen);
		syms[i] = static_cast<double>(bitStream[i]) * 2 - 1;
	}
	std::vector<double> tx_syms = conv(delayed_nyq_fil, upsample(syms, sps));
	//trimming the 0s at the end.
	for (int i = 0; i < sps - 1; i++) {
		tx_syms.pop_back();
	}

	std::vector<double> carrier(tx_syms.size());
	std::vector<double> tx(tx_syms.size());
	std::vector<double> noisy_tx(tx_syms.size());
	std::vector<double> time(tx_syms.size()); // time probably isn't necessary but it could be useful for troubleshooting purposes
	for (int i = 0; i < tx_syms.size(); i++) {
		time[i] = static_cast<double>(i) * (1.0 / fs);
		carrier[i] = cos(2.0 * M_PI * (static_cast<double>(fc) + f0) * time[i] + phi);
		tx[i] = tx_syms[i] * carrier[i];
		noisy_tx[i] = tx[i] + generate_noise(gen);
	}
	std::vector<double> rx = conv(noisy_tx, channel);
	//Okay, at this point the transmitter is done, now I need to export these vectors so I can do some matlab analysis and make sure everything looks correct.
	vec_to_file(carrier, "carrier.txt");
	vec_to_file(tx_syms, "tx_syms.txt");
	vec_to_file(rx, "rx.txt");
	vec_to_file(syms, "syms.txt");
}