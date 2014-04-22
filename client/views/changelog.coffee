TRS = @

Template.dropDeadChangelog.helpers
  changes: ->
    #console.log 'getting changes'
    d = Deps.currentComputation

    setTimeout ->
      d.invalidate()
    , 500
    
    #TRS.DropDeadChanges.find {timestamp: {$gte: new Date(Date.now() - 100)} }
    TRS.DropDeadChanges.find {}
