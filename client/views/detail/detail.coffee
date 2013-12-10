TRS = @

Template.detail.helpers
  persons: ->
    console.log @
    TRS.FacultyAllocations.find {semester: @semester, department: @department}

Template.detail.events
  'click .inline-edit .icon-edit': (e) ->
    console.log 'toggle edit'
    parent = $(e.currentTarget).parent '.inline-edit'
    $('.editing').not(parent).removeClass 'editing'
    parent.toggleClass 'editing'
  'click .icon-trash': (e,tpl) ->
    TRS.FacultyAllocations.remove {_id: @_id}
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
      courses: []
  'change .course input': (e) ->
    console.log 'change!'
    console.log e
    console.log @
  'click button.add-course': (e) ->
    console.log @
    TRS.FacultyAllocations.update {_id: @_id}, {$push: {courses: {prefix:'?', number: '?', credits: 3}}}

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
