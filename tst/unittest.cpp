#define BOOST_TEST_MODULE TestSuite
#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MAIN


#include <boost/test/unit_test.hpp>
#include <boost/test/tools/output_test_stream.hpp>
#include <iostream>
#include "output.hpp"

BOOST_AUTO_TEST_SUITE( TestSuite1 )

struct cout_redirect
{
    cout_redirect( std::streambuf * new_buffer )
        : old( std::cout.rdbuf( new_buffer ) )
    { }

    ~cout_redirect( )
    {
        std::cout.rdbuf( old );
    }

private:
    std::streambuf * old;
};

BOOST_AUTO_TEST_CASE( test1 )
{
    boost::test_tools::output_test_stream output;
    {
        cout_redirect guard( output.rdbuf( ) );

        output::msg("Test");
    }

    BOOST_CHECK( output.is_equal( "Test\n" ) );
}

BOOST_AUTO_TEST_SUITE_END()
