MONETARY LIBRARY
================

Monetary string formatting library in Teal (and Lua).

Overview
--------
Monetary is a pure-Teal library for string formatting numbers as currency.
It is very similar (but not identical to) ``strfmon`` as defined by GNU[1].

This library does not use the system locale. Instead we give a rough
approximation by allowing the user to define the symbols used for the thousands
separator, the decimal point, and currency symbol; which the default is ``,``,
``.``, and ``$`` respectively.

The library provides two functions, as shown by the record definition::

  local type M = record
    localize: function(thou: string, dec: string, cur: string)
    strfmon:  function(fmt: string, val: number): string
  end

Example Use
...........

Say we want to format numbers for for printing like::

  $    10,499.50
  $ 1,234,567.00

Or without cents, rounding the values::

  $    10,500   
  $ 1,234,567

Localized::

  €    10.499,50
  € 1.234.567,00

  €    10.500
  € 1.234.567

We can use code as shown in ``doc_monetary.tl``.

doc_monetary.tl
...............
::

  local m = require "monetary"
  local strfmon = m.strfmon
  local localize = m.localize

  local val1 = 10499.50
  local val2 = 1234567

  local fmt1 = "%#8.2n"    -- 8 digits to left of decimal; 2 to right
  local fmt2 = "%#8.0n"    --               "            ; 0 to right

  print( strfmon(fmt1, val1) )   -- $    10,499.50
  print( strfmon(fmt1, val2) )   -- $ 1,234,567.00
  print()
  print( strfmon(fmt2, val1) )   -- $    10,500
  print( strfmon(fmt2, val2) )   -- $ 1,234,567

  print()
  print("localized...")
  localize(".",",","€")

  print( strfmon(fmt1, val1) )   -- €    10.499,50
  print( strfmon(fmt1, val2) )   -- € 1.234.567,00
  print()
  print( strfmon(fmt2, val1) )   -- €    10.500
  print( strfmon(fmt2, val2) )   -- € 1.234.567 

Functions
---------

localize(thou: string, dec: string, cur: string)
................................................

``localize`` is used to set the separators used in the formatted string and the
currency symbol.  The library defaults to ``,`` for thousands, ``.`` for decimal
point and ``$`` for currency. To override these defaults call ``localize`` with
the desired separators.

For example, to set ``.`` as thousands, ``,`` as decimal point and ``€`` for currency::

  localize(".", ",", "€")

strfmon(fmt: string, val: number): string
.........................................

``strfmon`` is used to format a number as currency. It returns a string.

The ``fmt`` argument has a number of optional flags between the required opening
'%' and closing 'n'.  They are, in order::

  '^'      Turn off use of thousands grouping. By default grouping is enabled.

  '+','('  At most one of these is allowed. '+' is the default, which formats
           negative numbers using '-'. (note: '+' is the flag, and not '-',
           since '-' is used to indicate "left-justification".) To indicate
           negative numbers by enclosing them in parenthesis use the '(' flag.

  '!'      Turn off use of currency symbol. Currency symbol is on by default.

  '-'      The output is left-justified. By default output is right-justified.
           Justificaiton is only relevant when the entire field isn't filled.

  <w>      Minimum width of return string. If it is missing then default of 0
           is used, which means any width is ok, and no padding is relevant, nor
           is any justification relevant. If a width is given, and the output is
           less than the width, the output is padded with spaces (on the left,
           by default, on the right when '-' (left-justification) is enabled) in
           order to make the output be <w> characters wide.

  '#'      Activates the context for (left-of) or (left-of and right-of) spacing
           relevant to the decimal point (as opposed to spacing for the overall
           field, which is driven by <w> above). By default this context is not
           active.

           If the context is enabled then at least the <l> field is
           required. If the '.' symbol is included then the <r> field is
           required.

           <l>   Left-of decimal point minimum width, as measured in *digits*.
                 Ensures that space for at least <l> number of digits is
                 provided. If thousands grouping is enabled, then space for
                 those is also included (this space is not counted as a
                 'digit'). For example, #6 for a value of 1000 will create a
                 string "$  1,000", having ensured space for 6 digits.

          '.'    Seperates "left-of" from "right-of" decimal fields.

          <r>    Right-of decimal point minimum width, as measured in *digits*.
                 If <r> is 0, then no decimal point appears in the output, and
                 the value is rounded to be an integer. For other values of <r>
                 0's are padded to fill out the minimum width, or, if the
                 decimal portion exceeds <r> then the floating portion is
                 rounded to <r> places.


References
----------
[1] https://www.gnu.org/software/libc/manual/html_node/Formatting-Numbers.html
