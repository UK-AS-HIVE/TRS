TRS = @

Meteor.methods
  cloneSemester: (oldSemesterName, newSemesterName) ->
    oldSemester = TRS.Semesters.findOne { semester: oldSemesterName }
    delete oldSemester._id
    delete oldSemester.dropdead
    oldSemester.semester = newSemesterName
    TRS.Semesters.insert { semester: newSemesterName }
    oldAllocations = TRS.FacultyAllocations.find { semester: oldSemesterName }
    console.log 'copying individual allocations, total of ' + oldAllocations.count()
    oldAllocations.forEach (alloc) ->
      alloc.semester = newSemesterName
      delete alloc._id
      console.log 'Cloning allocation into new semester - ' + alloc.department + ' - ' + alloc.name
      TRS.FacultyAllocations.insert alloc, {validate: false} # TODO: why does validation fail here?
