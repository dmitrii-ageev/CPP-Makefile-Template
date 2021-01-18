#ifndef OUTPUT_HPP_
#define OUTPUT_HPP_

#include <iostream>
using namespace std;

namespace output
{
void msg(string const &text);
void msg(string const &text, string const &tag);
void info(string const &text);
void warning(string const &text);
void error(string const &text);
void debug(string const &text);
}

#endif
