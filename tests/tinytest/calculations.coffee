
Tinytest.add 'Calculation utility functions - sanitize pay amounts', (test) ->
  test.equal sanitizePayAmount('1234.00'), 1234
  test.equal sanitizePayAmount('1,234'), 1234
  test.equal sanitizePayAmount('$12.34'), 12.34

Tinytest.add 'Calculation utility functions - format currency', (test) ->
  test.equal formatCurrency('1234.00'), '$1,234.00'
  test.equal formatCurrency('1,234.00'), '$1,234.00'
  test.equal formatCurrency(1234), '$1,234.00'

Tinytest.add 'Calculation utility functions - convert fractions to floats', (test) ->
  test.equal fractionToFloat('2/3'), 2/3.0
  test.equal fractionToFloat('0.5'), 0.5
  
