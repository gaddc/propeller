{{
vga_40x18_rom_demo.spin v1.1 by Roger Williams

This demonstrates the basic capabilities of the vga_40x18_rom_text.spin
VGA driver.  The differences from Chip Gracey's original vga_text are
documented in vga_40x18_rom_text.spin.

Note that the VGA driver is hard coded for 80 MHz.  It won't work with
a different crystal or clkmode settings.

Revisions:
v1.1 added demonstrations of $C argument for user character bank
     switching and supporting named constants

}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  vga_basepin = 16

OBJ

  vga : "vga_40x18_rom_text"


PUB start | i

  vga.start(vga_basepin, @user_font)

  diamonds

  waitcnt(cnt+clkfreq*3)
  vga.str(string(vga#cursx,2,vga#cursy,2, vga#mode,vga#altcolor, {
    }"40 x 18 Character ROM Font VGA      "))
  vga.str(string(vga#cursx,2,vga#cursy,3, {
    }"by Roger Williams                   "))

  waitcnt(cnt+clkfreq*2)
  vga.str(string(vga#cursx,2,vga#cursy,4,     "                                    "))
  vga.str(string(vga#cursx,2,vga#cursy,5, vga#mode,vga#altcolor, vga#mode,vga#setalt+%%300, {
    }"Program + Data = 757 Longs          "))

  waitcnt(cnt+clkfreq*2)
  vga.str(string(vga#cursx,2,vga#cursy,6, vga#mode,vga#altcolor, vga#mode,vga#setalt+%%003))
  altstr(string("2 char colors + bkg within a line   "))
  vga.str(string(vga#cursx,2,vga#cursy,7, vga#mode,vga#altcolor, vga#mode,vga#setalt+%%030, {
    }"Each line has 3-color palette       "))

  waitcnt(cnt+clkfreq*2)
  vga.str(string(vga#cursx,2,vga#cursy,8,"                                    "))
  rvideo(9)

  waitcnt(cnt+clkfreq*2)
  rvideo(8)
  vga.str(string(vga#cursx,2,vga#cursy,9,"                                    "))
  
  vga.str(string(vga#cursx,2,vga#cursy,11, vga#mode,vga#altcolor, {
    }"                                    "))
  vga.str(string(vga#cursx,2,vga#cursy,12, {
    }"    And up to 512 16x16 pixel       "))
  vga.str(string(vga#cursx,2,vga#cursy,13, {
    }"    User Defined Characters         "))
  vga.str(string(vga#cursx,2,vga#cursy,14, {
    }"                                    "))

  across(10)
  ends(11)
  ends(12)
  ends(13)
  ends(14)
  across(15)

  waitcnt(cnt+clkfreq*2)
  i := cnt
  repeat
    '
    ' Cursoring to a line and changing the palette changes the colors
    ' on that line even without redrawing the characters.
    '
    ?i
    vga.str(string(vga#cursy,12,vga#mode))
    vga.out(vga#setalt+(i & $3F))
    vga.str(string(vga#cursy,13,vga#mode))
    vga.out(vga#setalt+(i & $3F))
    waitcnt(cnt+clkfreq)
   
pri diamonds
  repeat 9
    repeat 20
      vga.out(258)
      vga.out(259)
    repeat 20
      vga.out(260)
      vga.out(261)

pri altstr(str) | c, s
  c := 0
  repeat strsize(str)
    vga.out(vga#mode)
    c := 1-c
    vga.out(c)
    vga.out(byte[str++])  

pri rvideo(line)
  vga.str(string(vga#cursx,2,vga#cursy))
  vga.out(line)
  vga.str(string(vga#mode,vga#rvid, "Reverse", vga#mode,vga#normal, " Video ",{
      } vga#mode,vga#altcolor, "also ", vga#mode,vga#rvid+vga#altcolor, "Supported", vga#mode,vga#normal, "        "))

pri across(line)
  vga.str(string(vga#cursx,2,vga#cursy))
  vga.out(line)
  vga.str(string(vga#mode,vga#rvid,vga#mode,vga#cbank+1, {
    }"111111111111111111111111111111111111"))

pri ends(line)
  vga.out(vga#cursy)
  vga.out(line)
  vga.str(string(vga#cursx,2, vga#mode,vga#cbank+1, "1",vga#cursx,37,vga#cursy))
  vga.out(line)
  vga.str(string("1", vga#mode,vga#cbank))

dat
user_font
{
  The user defined chars must be reversed and interleaved like the ROM font,
  but in order to save memory they are only 16 pixels high.  This example
  shows a way to draw the font forward and un-interleaved so that the
  proptool will assemble it correctly.  Draw the left/lsb=0 character with
  2's and the right/lsb=1 character with 1's.  The reverse and add
  operations will take care of the interleave.

  There can be up to 512 user defined chars taking up to 16K Hub RAM.
}
        '256,257 / bank1 0,1
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%22002200_22002200 >< 32 + %%11001100_11001100 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        long  %%00220022_00220022 >< 32 + %%11111111_11111111 >< 32 
        '258,259 / bank 1 2,3
        long  %%00000000_00000002 >< 32 + %%10000000_00000000 >< 32 
        long  %%00000000_00000020 >< 32 + %%01000000_00000000 >< 32 
        long  %%00000000_00000200 >< 32 + %%00100000_00000000 >< 32 
        long  %%00000000_00002000 >< 32 + %%00010000_00000000 >< 32 
        long  %%00000000_00020000 >< 32 + %%00001000_00000000 >< 32 
        long  %%00000000_00200000 >< 32 + %%00000100_00000000 >< 32 
        long  %%00000000_02000000 >< 32 + %%00000010_00000000 >< 32 
        long  %%00000000_20000000 >< 32 + %%00000001_00000000 >< 32 
        long  %%00000002_00000000 >< 32 + %%00000000_10000000 >< 32 
        long  %%00000020_00000000 >< 32 + %%00000000_01000000 >< 32 
        long  %%00000200_00000000 >< 32 + %%00000000_00100000 >< 32 
        long  %%00002000_00000000 >< 32 + %%00000000_00010000 >< 32 
        long  %%00020000_00000000 >< 32 + %%00000000_00001000 >< 32 
        long  %%00200000_00000000 >< 32 + %%00000000_00000100 >< 32 
        long  %%02000000_00000000 >< 32 + %%00000000_00000010 >< 32 
        long  %%20000000_00000000 >< 32 + %%00000000_00000001 >< 32 
        '260,261 bank1 4,5
        long  %%20000000_00000000 >< 32 + %%00000000_00000001 >< 32 
        long  %%02000000_00000000 >< 32 + %%00000000_00000010 >< 32 
        long  %%00200000_00000000 >< 32 + %%00000000_00000100 >< 32 
        long  %%00020000_00000000 >< 32 + %%00000000_00001000 >< 32 
        long  %%00002000_00000000 >< 32 + %%00000000_00010000 >< 32 
        long  %%00000200_00000000 >< 32 + %%00000000_00100000 >< 32 
        long  %%00000020_00000000 >< 32 + %%00000000_01000000 >< 32 
        long  %%00000002_00000000 >< 32 + %%00000000_10000000 >< 32 
        long  %%00000000_20000000 >< 32 + %%00000001_00000000 >< 32 
        long  %%00000000_02000000 >< 32 + %%00000010_00000000 >< 32 
        long  %%00000000_00200000 >< 32 + %%00000100_00000000 >< 32 
        long  %%00000000_00020000 >< 32 + %%00001000_00000000 >< 32 
        long  %%00000000_00002000 >< 32 + %%00010000_00000000 >< 32 
        long  %%00000000_00000200 >< 32 + %%00100000_00000000 >< 32 
        long  %%00000000_00000020 >< 32 + %%01000000_00000000 >< 32 
        long  %%00000000_00000002 >< 32 + %%10000000_00000000 >< 32 
        '
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}    