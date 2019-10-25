/*

DU12SEM.CPP

JY

Mlaskal's semantic interface for DU1-2

*/

// CHANGE THIS LINE TO #include "du3456sem.hpp" WHEN THIS FILE IS COPIED TO du3456sem.cpp
#include "du12sem.hpp"
#include "duerr.hpp"

using namespace std;

namespace mlc {

	static char acii_to_upper_char(char c) {
		return ('a' <= c && c <= 'z') ? c ^ 0x20 : c;
	}

	string ascii_to_upper(const string s) {
		string result (s.length(), ' ');
		for (int i = 0; i < s.length(); i++) {
			result[i] = acii_to_upper_char(s[i]);
		}
		return result;
	}
};

/*****************************************/