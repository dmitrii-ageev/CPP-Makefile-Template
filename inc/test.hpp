#ifndef TEST_HPP_
#define TEST_HPP_

template <class Type>
Type max_of_four(Type a, Type b, Type c, Type d)
{
    Type data[]= {a,b,c,d}, max=a;
    for(int i=1; i<4; i++) if(max<data[i]) max=data[i];
    return max;
}

#endif
