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
      r = parseFloat payAmountString.replace /[^0-9\.-]+/g,""
      if isNaN r
        return 0
      return r
    catch e
      return 0

(exports ? @).currentlyAllocated = (myRank, context) ->
  console.log 'Calculating currentlyAllocated for "' + myRank + '"'
  sum = 0.0
  console.log 'Summing allocations...'
  console.log @
  console.log arguments
  if (myRank == '')
    console.log 'rank == blank'
    amounts = TRS.FacultyAllocations.find({semester: context.hash.semester || @semester, department: context.hash.department || @department}, {fields: {pay_amount: 1}}).forEach (doc) ->
      sum += sanitizePayAmount doc.pay_amount
      console.log sum
  else
    amounts = TRS.FacultyAllocations.find({semester: context.hash.semester || @semester, department: context.hash.department || @department, rank: myRank}, {fields: {pay_amount: 1}}).forEach (doc) ->
      sum += sanitizePayAmount doc.pay_amount
      console.log 'added ' + doc.pay_amount
  return (sum).toFixed(2)


