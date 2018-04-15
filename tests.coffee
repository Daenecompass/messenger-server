df_messages = [
  type: 0,
  platform: 'facebook',
  speech: 'One line\nOne.5 line [num 0800 800 800]\nSecond line which is really much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much too long much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much too long much much much much much much much much much much much much much much much much much much much much much much much muchd [more] much much much much much much much much much much much much much much much much much much much much much much much much much much too long [num 0800 800 800]\nThird\n[link http://google.com]\nFourth line\n[FU: Test3?: Test3]'
,
  type: 3,
  platform: 'facebook',
  imageUrl: 'https://i.imgur.com/KdcDG4k.jpg'
,
  type: 2,
  platform: 'facebook',
  title: 'Test4',
  replies: [ 'Reply 1', 'Reply 2', 'Reply 3' ]
,
  type: 3,
  platform: 'facebook',
  imageUrl: 'https://i.imgur.com/Cas1saY.jpg'
,
  type: 0,
  speech: 'One line\nOne.5 line [num 0800 800 800]\nSecond line which is really much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much too long much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much much too long much much much much much much much much much much much much much much much much much much much much much much much muchd [more] much much much much much much much much much much much much much much much much much much much much much much much much much much too long [num 0800 800 800]\nThird\n[link http://google.com]\nFourth line\n[FU: Test3?: Test3]'
]

{replace} = require 'lodash/fp'

e_to_u = replace /e/, 'u'

console.log e_to_u "hello"
