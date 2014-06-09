TRS = @

Template.detailHeader.events
  'click button#add-rank-type': (e,tpl) ->
    console.log 'add-rank-type'
    console.log @
    console.log e
    console.log tpl
    self = @
    bootbox.prompt 'Name of rank', (result) ->
      if result?
        console.log 'Trying to add ' + result + ' rank'
        data = TRS.SemesterDepartmentDetail.findOne {semester: Session.get('semester'), department: Session.get('department')}
        if data?
          console.log 'found data, updating it'
          console.log data
          TRS.SemesterDepartmentDetail.update {_id: data._id}, {$push: {breakdown: {lines: 0, rank: result, rate: '0'}}}
        else
          TRS.SemesterDepartmentDetail.insert
            semester: Session.get('semester')
            department: Session.get('department')
            breakdown: [{lines:0, rank: result, rate: '0'}]
          console.log 'didnt find semesterDepartmentDetail record, inserting'
  'change .breakdown input': (e, tpl) ->
    console.log 'Changed breakdown data'
    edit_form = $(e.target).parents '.inline-edit'
    id = edit_form.data 'id'
    index = edit_form.data 'index'
    property = $(e.target).data 'property'
    val = $(e.target).val()
    setter = {}
    setter['breakdown.' + index + '.' + property] = val
    depSem = TRS.SemesterDepartmentDetail.findOne {semester: Session.get('semester'), department: Session.get('department')}, {fields: {_id: 1}}
    TRS.SemesterDepartmentDetail.update depSem._id,
      $set: setter
  'click .breakdown .glyphicon-trash': (e,tpl) ->
    row = $(e.currentTarget).parents '.breakdown'
    index = row.data 'index'
    #id = $(e.currentTarget).parent('li.course').data 'id'
    console.log 'removing breakdown #' + index
    depSem = TRS.SemesterDepartmentDetail.findOne({semester: Session.get('semester'), department: Session.get('department')}, {fields: {_id:1, breakdown: 1}})
    id = depSem._id
    breakdown = depSem.breakdown
    breakdown.splice(index, 1)
    TRS.SemesterDepartmentDetail.update {_id: id},
      {$set: {breakdown: breakdown}}

  'change .salaryLoad input': (e, tpl) ->
    setter = {}
    setter['courseLoads.' + @key] = $(e.target).val()
    TRS.SemesterDepartmentDetail.update tpl.data._id,
      $set: setter

Template.detailHeader.helpers
  semester: -> Session.get 'semester'
  department: -> Session.get 'department'
  data: ->
    TRS.SemesterDepartmentDetail.findOne {semester: Session.get('semester'), department: Session.get('department')}
  currentlyAllocatedIsExpanded: ->
    Session.get 'isExpanded'
  currentlyAllocated: (r,c) -> currentlyAllocated r,c
  currentlyBudgeted: ->
    return formatCurrency( @value.lines * sanitizePayAmount(@value.rate) )
  linesAllocated: (context) ->
    sum = 0
    rank = @value.rank
    TRS.FacultyAllocations.find({semester: Session.get('semester'), department: Session.get('department')}).forEach (doc) ->
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
    depsem = TRS.SemesterDepartmentDetail.findOne
      semester: Session.get 'semester'
      department: Session.get 'department'
    if depsem? and depsem.courseLoads?
      return depsem.courseLoads
