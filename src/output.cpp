#include "output.hpp"
using namespace std;

void output::msg(string const &text)
{
    cout << text << endl;
}

void output::msg(string const &text, string const &tag)
{
    cout << tag << ": " << text << endl;
}

void output::info(string const &text)
{
    msg(text, "INFO");
}

void output::warning(string const &text)
{
    msg(text, "WARNING");
}

void output::error(string const &text)
{
    msg(text, "ERROR");
}

void output::debug(string const &text)
{
    msg(text, "DEBUG");
}
