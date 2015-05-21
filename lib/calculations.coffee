TRS = @

(exports ? @).fractionToFloat = (s) ->
  try
    s = s.split '/'
    if s.length is 2
      return parseInt(s[0])/(1.0*parseInt(s[1]))
    else
      return parseFloat s
  catch e
    return 0

(exports ? @).sanitizePayAmount = (payAmountString) ->
  try
    r = parseFloat (''+payAmountString).replace /[^0-9\.-]+/g,""
    if isNaN r
      return 0
    return r
  catch e
    return 0

(exports ? @).formatCurrency = (s) ->
  '$' + sanitizePayAmount(s).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')

(exports ? @).currentlyAllocated = (myRank, context) ->
  sum = 0.0
  if (myRank == '')
    amounts = TRS.FacultyAllocations.find({semester: context.hash.semester || @semester, department: context.hash.department || @department}, {fields: {payAmount: 1, rank: 1, pay_amount: 1, lines: 1, name: 1, department: 1, semester: 1, overload: 1, overloadAmount: 1}}).forEach (doc) ->
      sum += sanitizePayAmount doc.payAmount()
      console.log sum
  else
    depsem = TRS.SemesterDepartmentDetail.findOne {semester: context.hash.semester || @semester, department: context.hash.department || @department}
    rate = _.findWhere(depsem.breakdown, {rank: myRank}).rate
    amounts = TRS.FacultyAllocations.find({semester: context.hash.semester || @semester, department: context.hash.department || @department}, {fields: {payAmount: 1, lines: 1}}).forEach (doc) ->
      if doc.lines? and doc.lines[myRank]?
        sum += fractionToFloat(doc.lines[myRank]) * sanitizePayAmount rate
  return formatCurrency sum


