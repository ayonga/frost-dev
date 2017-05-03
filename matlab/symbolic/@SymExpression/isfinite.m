function y = isfinite(x)
    %ISFINITE True for finite elements of symbolic arrays.
    %   ISFINITE(X) returns an array that contains 1's where
    %   the elements of X are finite and 0's where they are not.
    %   For example, isfinite(sym([pi NaN Inf -Inf])) is [1 0 0 0].
    %
    %   For any X, exactly one of ISFINITE(X), ISINF(X), or ISNAN(X)
    %   is 1 for each element.
    %
    %   See also SYM/ISINF, SYM/ISNAN.

    y = ~isinf(x) & ~isnan(x);
end