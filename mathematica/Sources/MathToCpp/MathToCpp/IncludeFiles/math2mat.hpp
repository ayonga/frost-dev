#ifndef _MATH2MAT_HPP
#define _MATH2MAT_HPP

#include <cstring>
#include <cmath>
#include <vector>
#include <iostream>

#include <stdexcept>


#include "Eigen/Dense"

using namespace Eigen;

#define List(...) __VA_ARGS__

/* ArcTan */
// #define ArcTan(x,y)       (atan2((double)(y),(double)(x)))

#define common_assert_msg_ex(expr, msg, type) \
    if (!(expr)) \
    { \
        std::ostringstream os; \
        os << "Assert Error: " << #expr << std::endl << \
            "File: " << __FILE__ ":" << __LINE__ << std::endl << \
            "Function: " << __PRETTY_FUNCTION__ << std::endl << \
            "Message: " << msg << std::endl; \
        throw type(os.str()); \
    }

#define assert_size_matrix(X, rows_expected, cols_expected) \
    { \
        common_assert_msg_ex( \
            X.rows() == rows_expected && X.cols() == cols_expected, \
            "matrix [row, col] mismatch" << std::endl << \
                "actual: [" << X.rows() << ", " << X.cols() << "]" << std::endl << \
                "expected: [" << rows_expected << ", " << cols_expected << "]", \
            std::runtime_error); \
    }

#define assert_size_vector(X, size_expected) \
    { \
        common_assert_msg_ex( \
            X.size() == size_expected, \
            "matrix size mismatch" << std::endl << \
                "actual: " << X.size() << std::endl << \
                "expected: " << size_expected, \
            std::runtime_error); \
    }


#endif
