#pragma once

#include <string>
#include <vector>
using namespace ::std;


// manipulation de chaines
string utils_trim(std::string str);
vector<std::string> utils_split(const std::string s, char seperator);
void utils_strupr(const std::string& input, std::string& ouput);
int utils_stod(const std::string& input, double *ouput);

double utils_st2d(const std::string& input);
std::string utils_d2st(double val);

//string utils_format(const char *fmt, ...);
bool utils_caseInsensitiveStringCompare( const std::string& str1, const std::string& str2 );