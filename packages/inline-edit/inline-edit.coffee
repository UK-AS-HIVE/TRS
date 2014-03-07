(exports ? this).toggleEdit = (e) -> 
  console.log 'toggle edit'
  parent = $(e.currentTarget).parent '.inline-edit'
  $('.editing').not(parent).removeClass 'editing'
  parent.toggleClass 'editing'
  if parent.hasClass 'editing'
    Session.set 'editing_id', parent.attr 'id'
  else
    Session.set 'editing_id', '' 
