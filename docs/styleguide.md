# SQLib Style Guide

This document describes the standard that should be followed in the code of SQLib.

## Names

Names must be clear, rather than short. Avoid abbreviations.

Use snake_case with only lowercase letters and numbers.

Don't quote names, with the exception of labels. Names should never be reserved words.

Some objects exist at session level (@user_variables, prepared statements...). If they are conceptually private to a stored routine, use this format:
```
_<routine_name>_name
```

Collective names should not simply end with an `s`, because this is error prone (especially if we have a similar singular name). Instead, they should end with one of the following suffixes:

* _list (if the order is relevant)
* _set (if the order is not relevant)

### Local variables and parameters

Local variables should begin with the prefix: `v_`

In a stored function, parameters should begin with the prefix: `p_`

In a stored procedure, parameters should begin with one of the following prefixes:
* `in_` (for IN parameters)
* `out_` (for OUT parameters)
* `inout_` (for INOUT parameters)

This guarantess that the name is not reserved.

Don't use any prefix to identify the datatype.
