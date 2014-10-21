TRS = @

@ValidRanks =
  ['Professor',
   'Assoc',
   'Assist',
   'Senior Lecturer'
   'Lecturer',
   'PostDoc',
   'FTI',
   'PTI',
   'GA',
   'TA',
   'RA',
   'Fellow']

@Semesters = new Meteor.Collection 'semesters'
@Semesters.attachSchema new SimpleSchema
  semester:
    type: String
    label: 'Semester name'
    max: 200
  dropdead:
    type: String
    label: 'Drop-dead date'
    optional: true
    
@Departments = new Meteor.Collection 'departments'
@Departments.attachSchema new SimpleSchema
  department:
    type: String
    label: 'Department name'
  chairDMusers:
    type: [String]
    label: 'Usernames of authorized editors for this department'
    optional: true

@FacultyAllocations = new Meteor.Collection 'allocations'
@FacultyAllocations.attachSchema new SimpleSchema
  name:
    type: String
    label: 'Name'
  semester:
    type: String
    label: 'Semester of allocation'
  department:
    type: String
    label: 'Department of allocation'
  rank:
    type: String
    allowedValues: ValidRanks
    optional: true
  ukid:
    type: String
    optional: true
    label: 'UKID'
  buyout:
    type: Boolean
    optional: true
  buyoutPercent:
    type: Number
    optional: true
    min: 0
    max: 100
    label: 'buyout %'
  courseRelease:
    type: Boolean
    optional: true
    label: 'course release'
  courseReleaseAmount:
    type: Number
    optional: true
    min: 0
    label: 'amount of course release in # Credit Hrs'
  overload:
    type: Boolean
    optional: true
  overloadAmount:
    type: String
    optional: true
    label: 'overload amount in $'
  pay_amount:
    type: String
    optional: true
  notes:
    type: String
    optional: true
  paymentNotes:
    type: String
    optional: true
  'courses.$.prefix':
    type: String
    label: 'Course Prefix'
    max: 4
  'courses.$.number':
    type: String
    label: 'Course Number'
    max: 4
  'courses.$.credits':
    type: Number
    min: 0
    max: 5
  'courses.$.sections':
    type: String
    label: 'Sections'
    optional: true
  'courses.$.crosslisting':
    type: String
    label: 'Crosslisted as'
    optional: true
  lines:
    type: Object
    optional: true
    blackbox: true
    
@FacultyAllocations.helpers
  payAmount: ->
    payAmount = 0
    if @rank? and ['GA','TA','RA','FTI','PTI'].indexOf(@rank) > -1
      depsem = TRS.SemesterDepartmentDetail.findOne {semester: @semester, department: @department}, {fields: {breakdown: 1}}
      if depsem?
        _.each @lines, (v, k) ->
          standard = _.findWhere depsem.breakdown, {rank: k}
          payAmount += fractionToFloat(v) * sanitizePayAmount(standard.rate)
      payAmount += sanitizePayAmount @pay_amount
      payAmount = payAmount.toFixed(2)
    else
      payAmount = if @overload and @overloadAmount? then sanitizePayAmount(@overloadAmount).toFixed(2)
    return payAmount

@SemesterDepartmentDetail = new Meteor.Collection 'semesterDepartmentDetail'
@SemesterDepartmentDetail.attachSchema new SimpleSchema
  semester:
    type: String
    label: 'Semester of allocation'
  department:
    type: String
    label: 'Department of allocation'
  funding:
    type: String
    label: 'Approved funding'
    optional: true
  comments:
    type: String
    label: 'Comments pertaining to this department and semester'
    optional: true
  courseLoads:
    defaultValue:
      Professor: 4
      Associate: 4
      Assistant: 4
      'Senior Lecturer': 6
      Lecturer: 6
    type: new SimpleSchema
      Professor:
        type: Number
        min: 0
        max: 12
        defaultValue: 4
      Associate:
        type: Number
        min: 0
        max: 12
        defaultValue: 4
      Assistant:
        type: Number
        min: 0
        max: 12
        defaultValue: 4
      'Senior Lecturer':
        type: Number
        min: 0
        max: 12
        defaultValue: 6
      Lecturer:
        type: Number
        min: 0
        max: 12
        defaultValue: 0
  breakdown:
    type: [Object]
    label: 'Funding lines'
    optional: true
    defaultValue: [
        lines: 0
        rank: 'GA'
        rate: '0'
      ,
        lines: 0
        rank: 'TA'
        rate: '0'
      ,
        
        lines: 0
        rank: 'RA'
        rate: '0'
    ]
  'breakdown.$.lines':
    type: Number
    label: 'Number of lines'
    optional: true
  'breakdown.$.rank':
    type: String
    #allowedValues: ['GA','TA','RA','PTI','FTI']
    label: 'Rank'
    optional: true
  'breakdown.$.rate':
    type: String
    label: 'Rate per semester for this rank'
    optional: true
  
@Admins = new Meteor.Collection 'admins'
@Admins.attachSchema new SimpleSchema
  admins:
    type: [String]
    label: 'List of usernames who have admin privileges'

@DropDeadChanges = new Meteor.Collection 'dropDeadChanges'
@DropDeadChanges.attachSchema new SimpleSchema
  department:
    type: String
  semester:
    type: String
  username:
    type: String
  userId:
    type: String
  docId:
    type: String
  timestamp:
    type: Date
  fieldNames:
    type: [String]
    optional: true
  message:
    type: String
    optional: true
