{{ beau1button-demo.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ 1-button input routine v1.2         │ BR             │ (C)2012             │  3Jul2012     │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│ This code snippet demonstrates a method for implementing a simple 1-button user input      │
│ method as suggested by Beau: http://forums.parallax.com/showthread.php?p=921531            │
│                                                                                            │
│ Works surprisingly well and is the simplest, cheapest possible form of user input.  Ideal  │
│ for situations where user input is limited to some known set of values that the user does  │
│ not need to input very often (such as setting time or setting parameter values in an       │
│ embedded app).                                                                             │
│                                                                                            │
│ The exmaple provided is set up to be used with an 8X2 4-bit LCD interface but can easily   │
│ be modified to work with any other output device.  Two flavors are provided:               │
│ beau1button:     a basic no-frills 1-button input routine                                  │
│ beau1buttonBeep: same as above but with an audible beep user feedback; this is a           │
│                  significant enhancement to usability, at the expense of a piezo & pin     │
│                                                                                            │
│ Note that an LCD is not needed to run this demo, only a serial terminal...soft_lcd4_ez is  │
│ a serial terminal emulation of a 4-bit LCD that runs in Parallax Serial Terminal (or the   │
│ terminal program of your choice).                                                          │
│                                                                                            │
│ However, you do need to wire up a button.  A schematic for the button configuration is     │
│ embedded in the beau1button method documentation below.  A schematic for the (optional)    │
│ piezo speaker is shown in beep.spin.  Note that an LED can be used in place of the speaker │
│ to give a visual cue instead of an audible one; be sure to use a current-limiting resistor.│
│                                                                                            │
│ A good 4-bit LCD reference circuit can be found here:                                      │
│ http://www.parallax.com/Portals/0/Downloads/docs/cols/nv/prop/col/nvp2.pdf                 │
│                                                                                            │
│ V1.0 - Grandpa                                                                             │
│ V1.1 - Fixed several bugs in original (improper waitpeq mask & incorrect parameter names)  │
│        Added timeout/abort functionality to beau1buttonBeep                                │
│ V1.2 - Added presentMenuDisplay method to separate display routine from beau1button routine│                                                                                          │
│        Added example showing how to do sub-menus                                           │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}

CON
  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000
'hardware constants
  button       = 1                           'input button with pulldown
  peizo        = 0                           'piezo speaker (for audible beep)
  lcd_base_pin = 8                           'not used (only needed if jm_lcd4_ez is uncommented)
'software constants
  increment_menu = 80_000_000                'hold button 1 sec to incement menu
  timeout        = _xinfreq/5                'time to abort 1-button routine if no user input

 
OBJ
'  lcd  : "jm_lcd4_ez"              'the *real* 4-bit LCD driver
  lcd  : "soft_lcd4_ez"             'wrapper to make Propeller serial terminal look like jm_lcd4_ez
  SN   : "Simple_Numbers"
  rtc  : "PropellerRTC_Emulator"
  beep : "beep"


VAR
  long TimeString
  byte hour, minute, second, day, month, year
  long useSound

  
PUB main|ptr,i,Temp

  waitcnt(clkfreq * 5 + cnt)                      'wait 5 sec
  lcd.init(lcd_base_pin, 8, 2)                    'start lcd emulator in serial terminal
  rtc.Start(@TimeString)                          'init soft Clock

  useSound:=1                                     'set up beep feedback
  beep.init(peizo)
  beep.chirp

  repeat                                          'main loop to display time to LCD
    Temp:=TimeString                              'parse time from soft rtc object
    second := Temp & %111111
    Temp := Temp >> 6
    minute := Temp & %111111
    Temp := Temp >> 6
    hour := Temp & %1111
    Temp := Temp >> 4
    hour += (Temp & %1)*12
    Temp := Temp >> 1
    day := Temp & %11111
    Temp := Temp >> 5
    month := Temp & %1111
    Temp := Temp >> 4
    year := Temp & %11111


    lcd.cmd(lcd#CLS)                             'display date on LCD
    if month<10
      lcd.out(" ")
    lcd.dec(month)
    lcd.out("/")
    lcd.dec(day)
    lcd.out("/")
    lcd.dec(year)

    lcd.moveto(1,2)                              'display time on LCD
    if hour > 12
      hour-=12
    if hour<10
      lcd.out("0")
    lcd.dec(hour)
    lcd.out(":")
    if minute<10
      lcd.out("0")
    lcd.dec(minute)
    lcd.out(":")
    if second<10
      lcd.out("0")
    lcd.dec(second)

    if ina[button]                               'check for button press
      \setTime1Button                            'if pressed, set time...note abort trap here
    waitcnt( clkfreq + cnt )


pri setTime1Button|tmp
''routine to set day/time using a single button

    if useSound==1
      beep.chirp

    'date set sub-menu
    if beau1buttonBeep(button,@datesetStr,0,0,1)
       day:=beau1buttonBeep(button,@dayStr,day,1,31)
       month:=beau1buttonBeep(button,@monthStr,month,1,12)
       year:=beau1buttonBeep(button,@yearStr,year,0,20)

    'time set sub-menu
    if beau1buttonBeep(button,@timesetStr,0,0,1)
       hour:=beau1buttonBeep(button,@hourStr,hour,0,23)
       minute:=beau1buttonBeep(button,@minuteStr,minute,0,59)
       second:=beau1buttonBeep(button,@secondStr,second,0,59)

    rtc.Suspend                  ' Suspend Clock while being set
    rtc.SetYear(year)            ' 00 - 20 ... Valid from 2000 to 2020
    rtc.SetMonth(month)          ' 01 - 12 ... Month
    rtc.SetDate(day)             ' 01 - 31 ... Date
    rtc.SetMin(minute)           ' 00 - 59 ... Minute
    rtc.SetSec(second)           ' 00 - 59 ... Second
    if hour>11
      rtc.SetAMPM(1)             ' 0 = AM ; 1 = PM
      rtc.SetHour(hour-12)       ' 01 - 12 ... Hour
    else
      rtc.SetAMPM(0)             ' 0 = AM ; 1 = PM
      rtc.SetHour(hour)          ' 01 - 12 ... Hour
    rtc.Restart                  ' Start Clock after being set

    'turn audible feedback on/off
    useSound:=beau1buttonBeep(button,@soundStr,useSound,0,1)


dat
'prompt strings used in LCD user input
datesetStr byte "set date",0
dayStr    byte "set day",0
monthStr  byte "month",0
yearStr   byte "set year",0
timesetStr byte "set time",0
hourStr   byte "set hour",0
minuteStr byte "minute",0
secondStr byte "second",0
soundStr  byte "beep on?",0


pri beau1buttonBeep(buttonPin,strPtr,varSet,loLim,hiLim)|tmp
''1-button user input routine as suggested by Beau (with audible beeps & timeout):
''http://forums.parallax.com/showthread.php?p=921531
''press and release to increment digit
''press and hold to increment field
''if no user input after ~30 seconds, timeout will abort back to main
'buttonPin = input button pin number
'strPtr = pointer to message string output to line 1 of lcd
'varSet = variable to be set (determines initial setting
'loLim = lower limit of variable range
'hi Lim = high limit of variable range
'set up to work with a single button connected to the botton pin with a pulldown
'output via (user-supplied) presentMenuDisplay method
'
'                        220Ω
'    +3.3v ─[button]──┳──── buttonPin
'                      │
'                      10KΩ
'                      
'                     gnd
'

    waitpeq(0,|<buttonPin,0)                               'wait for button release
    repeat
      presentMenuDisplay(strPtr, varSet)                   'display user prompt string
'     waitpne(0,|<buttonPin,0)                             
      tmp:=0                                               
      repeat while ina[buttonPin]==0                       'wait for button press
        tmp++
        if tmp=>timeout                                    'timeout after ~30 seconds
          abort                                            'abort out of setTime1Button method
      tmp := cnt
      waitcnt(clkfreq/10 + cnt)                            'short delay to help debounce
      repeat while ina[buttonPin]                          'wait for button release
        if cnt - tmp > increment_menu
          if useSound==1
            beep.chirp
          waitpeq(0,|<buttonPin,0)
      if cnt - tmp > increment_menu                        'button held down > 1 sec?
         return varSet                                     'yes, return value
      else
         varSet++                                          'no, increment value
         if varSet > hiLim
           varSet := loLim
      waitcnt(clkfreq/5 + cnt)                             'short pause to help debounce


pri beau1button(buttonPin,strPtr,varSet,loLim,hiLim)|tmp
''Bare bones 1-button user input routine as suggested by Beau:
''http://forums.parallax.com/showthread.php?p=921531
''press and release to increment digit
''press and hold to increment field
'buttonPin = input button pin number
'strPtr = pointer to message string output to line 1 of lcd
'varSet = variable to be set (determines initial setting
'loLim = lower limit of variable range
'hi Lim = high limit of variable range
'set up to work with a single button connected to the botton pin with a pulldown
'output via (user-supplied) presentMenuDisplay method
'
'                        220Ω
'    +3.3v ─[button]──┳──── buttonPin
'                      │
'                      10KΩ
'                      
'                     gnd
'

    waitpeq(0,|<buttonPin,0)                           'wait for button release
    repeat
      presentMenuDisplay(strPtr, varSet)
'     waitpne(0,|<buttonPin,0)                             
      tmp:=0                                               
      repeat while ina[buttonPin]==0                       'wait for button press
        tmp++
        if tmp=>timeout                                    'timeout after ~30 seconds
          abort                                            'abort out of setTime1Button method
      tmp := cnt
      waitcnt(clkfreq/20 + cnt)                            'short delay to help debounce
      waitpeq(0,|<buttonPin,0)                             'wait for button release
      if cnt - tmp > increment_menu                        'button held down > 1 sec?
         return varSet                                     'yes, return value
      else
         varSet++                                          'no, increment value
         if varSet > hiLim
           varSet := loLim
      waitcnt(clkfreq/5 + cnt)                             'short pause to help debounce


pri presentMenuDisplay(strPtr, varSet)
'present menu display for menu input routine
'output via 4-bit LCD using jm_lcd4_ez object
      lcd.cmd(lcd#CLS)                                     'clear screen
      lcd.str(strPtr)
      lcd.moveto(1,2)
      lcd.dec(varSet)


DAT

{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                       │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    │
│associated documentation files (the "Software"), to deal in the Software without restriction,        │
│including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,│
│and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,│
│subject to the following conditions:                                                                 │
│                                                                                                     │                        │
│The above copyright notice and this permission notice shall be included in all copies or substantial │
│portions of the Software.                                                                            │
│                                                                                                     │                        │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT│
│LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION│
│WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}