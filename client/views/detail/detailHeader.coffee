TRS = @


Template.detailHeader.helpers
  data: ->
    TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}
  currentlyAllocatedIsExpanded: ->
    Session.get 'isExpanded'
  currentlyAllocated: (r,c) -> currentlyAllocated r,c
  currentlyBudgeted: ->
    return @value.lines * parseInt(@value.rate)
  linesAllocated: (context) ->
    sum = 0
    rank = @value.rank
    TRS.FacultyAllocations.find({semester: context.hash.semester, department: context.hash.department}).forEach (doc) ->
      if doc.lines and doc.lines[rank]
        sum += fractionToFloat doc.lines[rank]
    return sum
  rowClass: (context) ->
    ca = currentlyAllocated(@value.rank, context)
    if (@value.lines * parseInt(@value.rate)) < ca
      return 'error'
    else
      return ''
  salaryLoad: ->
    ### FIXME: This is hardcoded for a demo.  At least the numbers
    should be configurable by department-semester.
    ###
    'Full Professor': 4
    'Associate': 4
    'Assistant': 4
    'Lecturer': 6

