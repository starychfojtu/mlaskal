/*

	DU12SEM.H

	DB

	Mlaskal's semantic interface for DU1-2

*/

#ifndef __DU12SEM_H
#define __DU12SEM_H

#include <string>
#include "literal_storage.hpp"
#include "flat_icblock.hpp"
#include "dutables.hpp"
#include "abstract_instr.hpp"
#include "gen_ainstr.hpp"

using namespace std;

namespace mlc {

	string ascii_to_upper(const string s);

	int str_to_int(const string s);
}

#endif
