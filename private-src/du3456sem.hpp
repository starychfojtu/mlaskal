/*

	DU3456SEM.H

	DB

	Mlaskal's semantic interface for DU3-6

*/

#ifndef __DU3456SEM_H
#define __DU3456SEM_H

#include <string>
#include "literal_storage.hpp"
#include "flat_icblock.hpp"
#include "dutables.hpp"
#include "abstract_instr.hpp"
#include "gen_ainstr.hpp"
#include<tuple>
#include<cmath>
#include<cstdlib>

using namespace std;

namespace mlc {
	string ascii_to_upper(const string s);

	string get_leading_number(const string s);

	// Boolean indicates whether or not the value was stripped.
	tuple<int, bool> str_to_int(const string s);

	// Retrieves type by identifier.
	type_pointer get_type(symbol_tables* tab, ls_id_index idx, int idx_line);
}

#endif
