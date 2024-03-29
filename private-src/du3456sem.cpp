/*

DU3456SEM.CPP

JY

Mlaskal's semantic interface for DU3-6

*/

#include "du3456sem.hpp"
#include "duerr.hpp"
#include <cstdlib>
#include<cmath>

using namespace std;

namespace mlc {

	static char acii_to_upper_char(char c) {
		return ('a' <= c && c <= 'z') ? c ^ 0x20 : c;
	}

	string ascii_to_upper(const string s) {
		string result(s.length(), ' ');
		for (int i = 0; i < s.length(); i++) {
			result[i] = acii_to_upper_char(s[i]);
		}
		return result;
	}

	string get_leading_number(const string s)
	{
		int first_non_digit_index = -1;
		for (int i = 0; i < s.length(); i++) {
			if (!isdigit(s[i])) {
				first_non_digit_index = i;
			}
		}

		return first_non_digit_index == -1 ? s : s.substr(0, first_non_digit_index);
	}

	static int char_to_digit(const char c) {
		return (int)(c - '0');
	}

	tuple<int, bool> str_to_int(const string s) {
		int result = 0;
		bool stripped = false;
		for (auto c : s) {
			int new_result = 10 * result + char_to_digit(c);
			if (new_result <= result) {
				stripped = true;
			}
			result = new_result;
		}
		return make_tuple(result, stripped);
	}

	type_pointer get_type(symbol_tables* tab, ls_id_index idx, int idx_line) {
		auto type_ref = tab->find_symbol(idx)->access_type();
		if (!type_ref) {
			message(DUERR_NOTTYPE, idx_line, *idx);
		}

		return type_ref->type();
	}
};

/*****************************************/