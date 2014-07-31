
describe 'Calculation utility functions', ->
  it 'sanitizes pay amounts', ->
    expect(sanitizePayAmount '1234.00').toBe 1234
    expect(sanitizePayAmount '1,234').toBe 1234
    expect(sanitizePayAmount '$12.34').toBe 12.34
  it 'formats currency', ->
    expect(formatCurrency '1234.00').toBe '$1,234.00'
    expect(formatCurrency '1,234.00').toBe '$1,234.00'
    expect(formatCurrency 1234).toBe '$1,234.00'
  it 'converts fractions to floats', ->
    expect(fractionToFloat '2/3').toBe 2/3.0
    expect(fractionToFloat '0.5').toBe 0.5
  
