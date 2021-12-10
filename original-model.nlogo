globals [
 员工数总和
 死亡月
 结束标志
 用户转化比率
  累积用户数
  总固定资产
  工资占比
  房租占比
  货物占比
  获客占比
  固定资产占比
  new-资金消耗
  new-单月触达用户数
]
to setup
  ca
  system-dynamics-setup

    ifelse 商务人员平均月工资 * 商务人员数量 * 0.2 < 商务人员平均月工资
    [ set 商务管理层平均工资 商务人员平均月工资 * 2]
    [ set 商务管理层平均工资 商务人员平均月工资 * 商务人员数量 * 0.2 ]
  ifelse 技术人员平均月工资 * 技术人员数量 * 0.2 < 技术人员平均月工资
    [ set 技术管理层平均工资 技术人员平均月工资 * 2]
    [ set 技术管理层平均工资 技术人员平均月工资 * 技术人员数量 * 0.2 ]
  ifelse 运营人员平均月工资 * 运营人员数量 * 0.2 < 运营人员平均月工资
    [ set 运营管理层平均工资 运营人员平均月工资 * 2]
    [ set 运营管理层平均工资 运营人员平均月工资 * 运营人员数量 * 0.2 ]

end

to go

  if 结束标志 = 1
  [
    stop
  ]
  new_employee
  make_money


  system-dynamics-go
  set-current-plot "时间资金图"
  system-dynamics-do-plot



  if plot-pen-exists? "当月毛利" [
    set-current-plot-pen "当月毛利"
    plotxy ticks 当月毛利
  ]
 ;; set-current-plot-pen "固定资产"
  ;;plotxy ticks 固定资产


  set-current-plot "固定资产"
  set-current-plot-pen "固定资产"
  plotxy ticks 固定资产
  set-current-plot-pen "当月货物成本"
  plotxy ticks 当月货物成本

  if 资金 < 0 [
  set 死亡月 ticks
  set 结束标志 1
  ]

  let new-运营人员数量 ceiling (当月客户数 / 月用户与运营比)
  if new-运营人员数量 > 4
  [
    if new-运营人员数量 > 运营人员数量[
      set 运营人员数量 new-运营人员数量
    ]
  ]


  let new-累积用户数 (当月客户数 + 累积用户数)
  set 累积用户数 new-累积用户数

  set-current-plot "每月用户数"
  set-current-plot-pen "当月客户数"
  plotxy ticks 当月客户数
  set-current-plot-pen "累积用户数"
  plotxy ticks 累积用户数

  let new-总固定资产 (新增员工数 * 每员工办公设备 + 总固定资产)
  set 总固定资产 new-总固定资产

  ifelse 当月货物成本 > 默认货物成本
  [
    if (当月货物成本 - 默认货物成本) > 新增货物成本
    [set 新增货物成本 (当月货物成本 - 默认货物成本)
    ]
  ][
    set 新增货物成本 0
  ]

  set new-资金消耗 资金消耗
  set 工资占比 (员工月工资总和 + 老板月工资) / new-资金消耗
  set 房租占比 月房租 / new-资金消耗
  set 货物占比 新增货物成本 / new-资金消耗
  set 获客占比 当月获客成本 / new-资金消耗
  set 固定资产占比 固定资产投入 / new-资金消耗

  set-current-plot "成本比例"
  set-current-plot-pen "工资占比"
  plotxy ticks 工资占比
  set-current-plot-pen "房租占比"
  plotxy ticks 房租占比
  set-current-plot-pen "货物占比"
  plotxy ticks 货物占比
  set-current-plot-pen "获客占比"
  plotxy ticks 获客占比
  set-current-plot-pen "固定资产占比"
  plotxy ticks 固定资产占比

  ;;print-all

end

to new_employee
  ifelse ticks < 6 [
    set 新增员工数 3
    let new-员工数总和 ( 员工数总和 + 新增员工数 )
    set 员工数总和 new-员工数总和

    set 员工月工资总和 (员工数总和 * 员工平均工资)
  ]
  [
    ifelse 员工数总和 < 最大员工数量
    [
      let new-新增员工数 ( 最大员工数量 - 员工数总和 )
      set 新增员工数 new-新增员工数
      if 员工数总和-稳定 < 最大员工数量
      [
        set 其他人员数量 (最大员工数量 - 员工数总和-稳定)
      ]

    ]
    [ set 新增员工数 0
    ]
    set 员工数总和  (商务人员数量 + 技术人员数量 + 行政人员数量 + 运营人员数量 + 财务人员数量 + 其他人员数量)
    set 员工月工资总和 (商务人员月工资总和 + 技术人员月工资总和 + 行政人员月工资总和 + 运营人员月工资总和 + 财务人员月工资总和 + 其他人员月工资总和)
  ]

;;to print-all
;;  output-print (word "人员数量: " 商务人员数量)

end

to make_money
  ;if ticks = 产品投放月 [
  ; set 用户转化比率设置 默认用户转化比率
  ;]
  ifelse ticks < 产品投放月 [
    set 用户转化比率 0
    set new-单月触达用户数  0
  ][
    set new-单月触达用户数 单月触达用户数
    set 默认用户转化比率 用户转化比率设置
    if 用户增长模式 =  "平滑增长曲线"
    [
      set 用户转化比率 (15 ^ (- ticks + 产品投放月 + 2) + 1) ^ -1 *  默认用户转化比率 * ((random 10) / 10 + 0.5)
    ]
    if 用户增长模式 =  "直线增长"
    [
      ifelse (ticks - 产品投放月) < 6
      [
        set 用户转化比率 0.2 * (ticks - 产品投放月) *  默认用户转化比率 * ((random 10) / 10 + 0.5)
       ][
           set 用户转化比率  默认用户转化比率 * ((random 10) / 10 + 0.5)
        ]
    ]
    ;使用逻辑斯蒂函数绘制一个用户的平滑增长曲线
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
26
17
77
69
-1
-1
14.33333333333334
1
10
1
1
1
0
1
1
1
-1
1
-1
1
1
1
1
ticks
1.0

BUTTON
322
35
404
69
初始设置
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
413
35
495
68
持续运行
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
627
219
796
264
资金
资金
17
1
11

PLOT
627
14
1146
211
时间资金图
月
元
1.0
24.0
0.0
2500000.0
true
true
"" ""
PENS
"资金" 1.0 0 -7500403 true "" ""
"当月毛利" 1.0 0 -2674135 true "" ""

MONITOR
404
324
494
369
员工月工资总和
员工月工资总和
17
1
11

MONITOR
511
274
599
319
NIL
当月毛利
17
1
11

INPUTBOX
93
21
190
81
启动资金
2500000.0
1
0
Number

MONITOR
1215
16
1342
61
NIL
商务管理层平均工资
17
1
11

MONITOR
404
163
506
208
实际员工数总和
员工数总和
17
1
11

INPUTBOX
982
274
1083
335
单个用户单价
300.0
1
0
Number

INPUTBOX
1088
274
1189
334
单个用户毛利
0.5
1
0
Number

INPUTBOX
768
275
870
335
单月触达用户数
100000.0
1
0
Number

INPUTBOX
875
275
977
335
用户转化比率设置
0.03
1
0
Number

INPUTBOX
200
87
297
147
初始入市手续费
100000.0
1
0
Number

MONITOR
814
219
878
264
当前月份
ticks
17
1
11

MONITOR
404
375
493
420
当月房租
月房租
17
1
11

MONITOR
510
375
600
420
NIL
当月客户数
17
1
11

PLOT
27
443
389
574
每月用户数
月
人
0.0
24.0
0.0
1000.0
true
true
"" ""
PENS
"当月客户数" 1.0 0 -16777216 true "" ""
"累积用户数" 1.0 1 -2674135 true "" ""

MONITOR
94
215
183
260
NIL
其他人员数量
17
1
11

MONITOR
94
160
183
205
NIL
行政人员数量
17
1
11

MONITOR
1215
71
1342
116
NIL
技术管理层平均工资
17
1
11

MONITOR
1215
123
1342
168
NIL
运营管理层平均工资
17
1
11

MONITOR
1218
438
1345
483
NIL
老板月工资
17
1
11

MONITOR
891
219
955
264
NIL
死亡月
17
1
11

MONITOR
510
426
600
471
NIL
用户转化比率
6
1
11

BUTTON
508
35
590
68
步进执行
\ngo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
28
273
390
417
固定资产
月
元
0.0
24.0
0.0
100000.0
true
true
"" ""
PENS
"固定资产" 1.0 1 -16777216 true "" ""
"当月货物成本" 1.0 0 -14439633 true "" ""

INPUTBOX
200
20
297
80
最大员工数量
20.0
1
0
Number

MONITOR
404
477
494
522
NIL
当月获客成本
17
1
11

MONITOR
404
527
495
572
NIL
固定资产投入
17
1
11

MONITOR
510
325
599
370
当月资金消耗
资金消耗
17
1
11

MONITOR
293
163
382
208
NIL
运营人员数量
17
1
11

INPUTBOX
93
88
190
148
产品投放月
6.0
1
0
Number

MONITOR
402
218
506
263
NIL
默认货物成本
17
1
11

MONITOR
293
217
382
262
NIL
技术人员数量
17
1
11

MONITOR
196
162
285
207
NIL
商务人员数量
17
1
11

MONITOR
195
216
284
261
NIL
财务人员数量
17
1
11

MONITOR
404
426
494
471
NIL
当月税费
17
1
11

MONITOR
403
274
494
319
NIL
当月货物成本
17
1
11

MONITOR
1216
175
1343
220
NIL
运营人员平均月工资
17
1
11

MONITOR
1217
230
1344
275
NIL
商务人员平均月工资
17
1
11

MONITOR
1216
281
1343
326
NIL
技术人员平均月工资
17
1
11

MONITOR
1216
333
1343
378
NIL
行政人员平均月工资
17
1
11

MONITOR
1217
385
1344
430
NIL
财务人员平均月工资
17
1
11

CHOOSER
626
276
764
321
用户增长模式
用户增长模式
"平滑增长曲线" "直线增长" "抛物线增长"
0

PLOT
622
376
1142
526
成本比例
月份
占比
1.0
32.0
0.0
1.0
true
true
"" ""
PENS
"工资占比" 1.0 1 -2674135 true "" ""
"货物占比" 1.0 1 -13345367 true "" ""
"获客占比" 1.0 1 -10899396 true "" ""
"房租占比" 1.0 1 -7500403 true "" ""
"固定资产占比" 1.0 1 -5825686 true "" ""

@#$#@#$#@
## WHAT IS IT?

本项目主要用于模拟一个公司的生存演化过程。

由于资金是一个公司的核心要素，我们的模拟以资金为基础，主要通过计算公司资金的方式，来模拟一个公司可能的生命周期。从公司有一个充足的自有资金开始，通过公司的商业模型，不断消耗资金，不断盈利，从而模拟出一个公司的可能历程。

本项目主要使用了Netlogo的系统动力学模型。

采用Netlogo是因为它的入门门槛低，易于学习，并且可以自定义模型。
使用系统动力学模型，是因为它非常适于模拟公司的资金变化情况。
我们采用了netlogo web的方式提供模型文件，这样可以在浏览器中直接使用。
由于本项目的初期目标是：展现出来，给大家做为公司决策的辅助工具。所以不需要太多的反复大量模拟，大量的计算，NetLogo足够。后期，如果需要最优方案的模拟，可以考虑其他的方式。


项目地址: https://github.com/openerserver/CorpModel

## 联系

LarryWang | Wechat: wang686ff | Email: openercn@gmail.com
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
1.0
    org.nlogo.sdm.gui.AggregateDrawing 98
        org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 154 135 30 30
        org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 169 183 30 30
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 857 16 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "商务管理层平均工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1537 58 50 50
            org.nlogo.sdm.gui.WrappedConverter "ceiling(出项税 - 进项税 )" "当月税费"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1514 178 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.13" "增值税率"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1645 134 50 50
            org.nlogo.sdm.gui.WrappedConverter "当月销售额  / (1 + 增值税率)   * 增值税率" "出项税"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1643 79 50 50
            org.nlogo.sdm.gui.WrappedConverter "(当月货物成本 / (1 + 增值税率) * 增值税率)" "进项税"
        org.nlogo.sdm.gui.BindingConnection 2 1543 182 1557 103 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 7
            org.jhotdraw.contrib.ChopDiamondConnector REF 5
        org.nlogo.sdm.gui.BindingConnection 2 1655 148 1576 93 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 9
            org.jhotdraw.contrib.ChopDiamondConnector REF 5
        org.nlogo.sdm.gui.BindingConnection 2 1647 99 1582 87 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 11
            org.jhotdraw.contrib.ChopDiamondConnector REF 5
        org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 775 5 30 30
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1418 782 50 50
            org.nlogo.sdm.gui.WrappedConverter "100" "销售额与财务人员比"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1576 653 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "其他人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1678 649 50 50
            org.nlogo.sdm.gui.WrappedConverter "6000" "其他人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1554 576 50 50
            org.nlogo.sdm.gui.WrappedConverter "其他人员数量 * 其他人员平均月工资" "其他人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1588 274 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.03" "默认用户转化比率"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1451 276 50 50
            org.nlogo.sdm.gui.WrappedConverter "默认用户转化比率 * 单月触达用户数 * 单个客户成本" "默认货物成本"
        org.nlogo.sdm.gui.BindingConnection 2 1595 658 1584 620 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 25
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
        org.nlogo.sdm.gui.BindingConnection 2 1687 664 1594 610 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 27
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
        org.nlogo.sdm.gui.BindingConnection 2 1588 299 1500 300 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 31
            org.jhotdraw.contrib.ChopDiamondConnector REF 33
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 51 636 50 50
            org.nlogo.sdm.gui.WrappedConverter "6000" "商务人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 217 630 50 50
            org.nlogo.sdm.gui.WrappedConverter "3" "商务人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 118 555 50 50
            org.nlogo.sdm.gui.WrappedConverter "商务人员平均月工资 * 商务人员数量 + \nceiling(商务人员数量 / 10) * 商务管理层平均工资" "商务人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 374 663 50 50
            org.nlogo.sdm.gui.WrappedConverter "8000" "技术人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 517 659 50 50
            org.nlogo.sdm.gui.WrappedConverter "10" "技术人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 439 566 50 50
            org.nlogo.sdm.gui.WrappedConverter "技术人员平均月工资 * 技术人员数量" "技术人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 691 665 50 50
            org.nlogo.sdm.gui.WrappedConverter "5000" "行政人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 844 664 50 50
            org.nlogo.sdm.gui.WrappedConverter "ceiling((商务人员数量 + 技术人员数量 + 运营人员数量 + 财务人员数量)/ 总人员与行政比)" "行政人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 993 660 50 50
            org.nlogo.sdm.gui.WrappedConverter "6000" "运营人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1140 659 50 50
            org.nlogo.sdm.gui.WrappedConverter "4" "运营人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 519 772 50 50
            org.nlogo.sdm.gui.WrappedConverter "1000" "月用户与技术比"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 213 763 50 50
            org.nlogo.sdm.gui.WrappedConverter "100" "月用户与商务比"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 846 801 50 50
            org.nlogo.sdm.gui.WrappedConverter "25" "总人员与行政比"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1137 778 50 50
            org.nlogo.sdm.gui.WrappedConverter "300" "月用户与运营比"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1277 655 50 50
            org.nlogo.sdm.gui.WrappedConverter "1" "财务人员数量"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1381 656 50 50
            org.nlogo.sdm.gui.WrappedConverter "6000" "财务人员平均月工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1235 576 50 50
            org.nlogo.sdm.gui.WrappedConverter "财务人员数量 * 财务人员平均月工资" "财务人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1277 782 50 50
            org.nlogo.sdm.gui.WrappedConverter ";; 财务人员的数量 与 下游分销商的数量有密切关系\n\n100" "分销商与财务人员比"
        org.nlogo.sdm.gui.BindingConnection 2 87 647 131 593 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 44
            org.jhotdraw.contrib.ChopDiamondConnector REF 48
        org.nlogo.sdm.gui.BindingConnection 2 227 644 157 590 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 46
            org.jhotdraw.contrib.ChopDiamondConnector REF 48
        org.nlogo.sdm.gui.BindingConnection 2 238 763 241 679 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 66
            org.jhotdraw.contrib.ChopDiamondConnector REF 46
        org.nlogo.sdm.gui.BindingConnection 2 409 673 453 605 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 50
            org.jhotdraw.contrib.ChopDiamondConnector REF 54
        org.nlogo.sdm.gui.BindingConnection 2 530 670 475 604 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 52
            org.jhotdraw.contrib.ChopDiamondConnector REF 54
        org.nlogo.sdm.gui.BindingConnection 2 543 772 542 708 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 64
            org.jhotdraw.contrib.ChopDiamondConnector REF 52
        org.nlogo.sdm.gui.BindingConnection 2 870 801 869 713 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 68
            org.jhotdraw.contrib.ChopDiamondConnector REF 58
        org.nlogo.sdm.gui.BindingConnection 2 1162 778 1164 708 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 70
            org.jhotdraw.contrib.ChopDiamondConnector REF 62
        org.nlogo.sdm.gui.BindingConnection 2 1293 663 1268 617 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 72
            org.jhotdraw.contrib.ChopDiamondConnector REF 76
        org.nlogo.sdm.gui.BindingConnection 2 1302 782 1302 705 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 78
            org.jhotdraw.contrib.ChopDiamondConnector REF 72
        org.nlogo.sdm.gui.BindingConnection 2 1429 795 1315 691 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 23
            org.jhotdraw.contrib.ChopDiamondConnector REF 72
        org.nlogo.sdm.gui.BindingConnection 2 1389 672 1276 609 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 74
            org.jhotdraw.contrib.ChopDiamondConnector REF 76
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1328 176 50 50
            org.nlogo.sdm.gui.WrappedConverter "单个用户单价 * (1 - 单个用户毛利)" "单个客户成本"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1348 327 50 50
            org.nlogo.sdm.gui.WrappedConverter "单个人员每月工位费 * 最大员工数量" "月房租"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1348 430 50 50
            org.nlogo.sdm.gui.WrappedConverter "1200" "单个人员每月工位费"
        org.nlogo.sdm.gui.ReservoirFigure "attributes" "attributes" 1 "FillColor" "Color" 192 192 192 693 81 30 30
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 626 312 50 50
            org.nlogo.sdm.gui.WrappedConverter "2" "新增员工数"
        org.nlogo.sdm.gui.BindingConnection 2 1373 430 1373 377 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 120
            org.jhotdraw.contrib.ChopDiamondConnector REF 118
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 701 433 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "员工月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 715 568 50 50
            org.nlogo.sdm.gui.WrappedConverter "行政人员平均月工资 * 行政人员数量" "行政人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1015 572 50 50
            org.nlogo.sdm.gui.WrappedConverter "运营人员平均月工资 * 运营人员数量" "运营人员月工资总和"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1202 179 50 50
            org.nlogo.sdm.gui.WrappedConverter "ceiling (new-单月触达用户数 * 用户转化比率)" "当月客户数"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1173 381 50 50
            org.nlogo.sdm.gui.WrappedConverter "商务人员数量 + 技术人员数量 + 行政人员数量 + 运营人员数量 + 财务人员数量 + 其他人员数量" "员工数总和-稳定"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 678 219 50 50
            org.nlogo.sdm.gui.WrappedConverter "新增员工数 * 每员工办公设备" "固定资产投入"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 723 313 50 50
            org.nlogo.sdm.gui.WrappedConverter "10000" "每员工办公设备"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 878 433 50 50
            org.nlogo.sdm.gui.WrappedConverter "ceiling ((商务人员平均月工资 + 技术人员平均月工资 + 运营人员平均月工资 + 行政人员平均月工资 + 财务人员平均月工资 + 其他人员平均月工资) / 6)" "员工平均工资"
        org.nlogo.sdm.gui.BindingConnection 2 163 575 705 462 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 48
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 480 582 709 466 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 54
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 737 570 728 480 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 130
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 1022 589 743 465 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 132
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 1240 595 745 463 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 76
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 1557 597 747 461 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 29
            org.jhotdraw.contrib.ChopDiamondConnector REF 128
        org.nlogo.sdm.gui.BindingConnection 2 720 669 735 613 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 56
            org.jhotdraw.contrib.ChopDiamondConnector REF 130
        org.nlogo.sdm.gui.BindingConnection 2 854 678 754 603 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 58
            org.jhotdraw.contrib.ChopDiamondConnector REF 130
        org.nlogo.sdm.gui.BindingConnection 2 1023 665 1035 617 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 60
            org.jhotdraw.contrib.ChopDiamondConnector REF 132
        org.nlogo.sdm.gui.BindingConnection 2 1150 673 1054 607 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 62
            org.jhotdraw.contrib.ChopDiamondConnector REF 132
        org.nlogo.sdm.gui.BindingConnection 2 739 321 711 260 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 140
            org.jhotdraw.contrib.ChopDiamondConnector REF 138
        org.nlogo.sdm.gui.BindingConnection 2 659 320 694 260 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 123
            org.jhotdraw.contrib.ChopDiamondConnector REF 138
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1221 57 50 50
            org.nlogo.sdm.gui.WrappedConverter "ceiling (当月客户数 * 单个用户毛利 * 单个用户单价 )" "当月毛利"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1304 57 50 50
            org.nlogo.sdm.gui.WrappedConverter "单个客户成本 * 当月客户数" "当月货物成本"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1418 56 50 50
            org.nlogo.sdm.gui.WrappedConverter "当月客户数 * 单个用户单价" "当月销售额"
        org.nlogo.sdm.gui.BindingConnection 2 1230 182 1242 103 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 134
            org.jhotdraw.contrib.ChopDiamondConnector REF 180
        org.nlogo.sdm.gui.BindingConnection 2 1348 180 1333 102 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 116
            org.jhotdraw.contrib.ChopDiamondConnector REF 182
        org.nlogo.sdm.gui.BindingConnection 2 1238 190 1317 95 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 134
            org.jhotdraw.contrib.ChopDiamondConnector REF 182
        org.nlogo.sdm.gui.BindingConnection 2 1242 194 1427 90 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 134
            org.jhotdraw.contrib.ChopDiamondConnector REF 184
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1063 177 50 50
            org.nlogo.sdm.gui.WrappedConverter "0.5" "单个用户触达成本"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 1109 58 50 50
            org.nlogo.sdm.gui.WrappedConverter "单个用户触达成本 * new-单月触达用户数" "当月获客成本"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 856 73 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "技术管理层平均工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 857 133 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "运营管理层平均工资"
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 860 197 50 50
            org.nlogo.sdm.gui.WrappedConverter "30000" "老板月工资"
        org.nlogo.sdm.gui.BindingConnection 2 1094 183 1127 101 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 198
            org.jhotdraw.contrib.ChopDiamondConnector REF 200
        org.nlogo.sdm.gui.BindingConnection 2 1216 189 1144 97 NULL NULL 0 0 0
            org.jhotdraw.contrib.ChopDiamondConnector REF 134
            org.jhotdraw.contrib.ChopDiamondConnector REF 200
        org.nlogo.sdm.gui.ConverterFigure "attributes" "attributes" 1 "FillColor" "Color" 130 188 183 359 294 50 50
            org.nlogo.sdm.gui.WrappedConverter "0" "新增货物成本"
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 436 200 60 40
            org.nlogo.sdm.gui.WrappedStock "用户数" "10" 0
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 436 116 60 40
            org.nlogo.sdm.gui.WrappedStock "固定资产" "0" 0
        org.nlogo.sdm.gui.RateConnection 3 694 98 601 113 508 128 NULL NULL 0 0 0
            org.jhotdraw.figures.ChopEllipseConnector REF 122
            org.jhotdraw.standard.ChopBoxConnector REF 218
            org.nlogo.sdm.gui.WrappedRate "新增员工数 * 每员工办公设备" "办公固定资产"
                org.nlogo.sdm.gui.WrappedReservoir  REF 219 0
        org.nlogo.sdm.gui.RateConnection 3 424 145 311 170 199 196 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 218
            org.jhotdraw.figures.ChopEllipseConnector REF 2
            org.nlogo.sdm.gui.WrappedRate "总固定资产 * 0.01" "折旧" REF 219
                org.nlogo.sdm.gui.WrappedReservoir  0
        org.nlogo.sdm.gui.StockFigure "attributes" "attributes" 1 "FillColor" "Color" 225 225 182 436 26 60 40
            org.nlogo.sdm.gui.WrappedStock "资金" "启动资金 - 默认货物成本 - 初始入市手续费 - 新增货物成本" 0
        org.nlogo.sdm.gui.RateConnection 3 424 60 303 103 183 146 NULL NULL 0 0 0
            org.jhotdraw.standard.ChopBoxConnector REF 230
            org.jhotdraw.figures.ChopEllipseConnector REF 1
            org.nlogo.sdm.gui.WrappedRate "员工月工资总和 + 月房租 + 当月获客成本 + 固定资产投入 + 老板月工资 + 当月税费 + 新增货物成本" "资金消耗" REF 231
                org.nlogo.sdm.gui.WrappedReservoir  0
        org.nlogo.sdm.gui.RateConnection 3 777 20 642 31 508 42 NULL NULL 0 0 0
            org.jhotdraw.figures.ChopEllipseConnector REF 22
            org.jhotdraw.standard.ChopBoxConnector REF 230
            org.nlogo.sdm.gui.WrappedRate "当月毛利" "利润1"
                org.nlogo.sdm.gui.WrappedReservoir  REF 231 0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
