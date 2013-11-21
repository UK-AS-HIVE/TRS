TRS = @

Template.detail.helpers
  persons: ->
    console.log @
    TRS.FacultyAllocations.find {semester: @semester, department: @department}


Template.detail.events
  'click button#add': (e) ->
    console.log @
    TRS.FacultyAllocations.insert
      name: 'click to edit'
      semester: @semester
      department: @department
      rank: 'unspecified'
      buyout: 'n/a'
      pay_amount: null
      comment: ''
      courses: {}

Template.detail.rendered = ->
  template = @
  $(@findAll '.editable').editable (value, settings) ->
    console.log 'edited'
    $el = $(@)
    id = $el.data 'id'
    property = $el.data 'property'
    update = {}
    update[property] = value
    TRS.FacultyAllocations.update id, {$set: update }
    value

Template.detailRankSelect.helpers
  selectedOption: (rank) ->
    ret = 'value="' + rank + '"'
    ret += ' selected' if @rank is rank 
    new Handlebars.SafeString ret

Template.detailRankSelect.rendered = ->
  data = @data

  $(@find 'select.rank').select2().change (e) ->
    TRS.FacultyAllocations.update {_id: data._id}, {$set: { rank: e.val }}
