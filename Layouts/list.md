# MDS Layouts
## Conventional
2x magnification. Stacked vertically.
**MDS_VStack(clip c, int "frame", int "frame2")**
**MDS_VstackA(clip c, int "frame", int "frame2")**
![VStack()](VStack.png)

Stacked vertically with an effectively 92 (default) pixel gap between the screens.
**MDS_VStackGap(clip c, int "frame", int "frame2", string "gap")**
**MDS_VStackGapA(clip c, int "frame", int "frame2", string "gap")**
![VStackGap()](VStackGap.png)

4x magnification. Top screen centered, Bottom Screen centered but off screen below.
**MDS_TopV(clip c, int "frame", int "frame2")**
**MDS_TopVA(clip c, int "frame", int "frame2")**
![TopV()](TopV.png)

4x magnification. Bottom screen centered, Top Screen centered but off screen above.
**MDS_BotV(clip c, int "frame", int "frame2")**
**MDS_BotVA(clip c, int "frame", int "frame2")**
![BotV()](BotV.png)

4x magnification. Top screen centered, Bottom Screen off screen to the right.
**MDS_TopH(clip c, int "frame", int "frame2")**
**MDS_TopHA(clip c, int "frame", int "frame2")**
![TopH()](TopH.png)

4x magnification. Bottom screen centered, Top Screen but off screen to the left.
**MDS_BotH(clip c, int "frame", int "frame2")**
**MDS_BotHA(clip c, int "frame", int "frame2")**
![BotH()](BotH.png)

4x magnification. Bring Top screen in over the Bottom.
**MDS_QuickTop(clip c, int "frame", int "frame2")**
**MDS_QuickTopA(clip c, int "frame", int "frame2")**
![QuickTop()](QuickTop.png)

4x magnification. Bring Bottom screen in over the Top.
**MDS_QuickBot(clip c, int "frame", int "frame2")**
**MDS_QuickBotA(clip c, int "frame", int "frame2")**
![QuickBot()](QuickBot.png)

Top screen @ 4x, centered. Bottom screen @ 1x out of the viewport to the lower right.
**MDS_TopO(clip c, int "frame", int "frame2")**
**MDS_TopOA(clip c, int "frame", int "frame2")**
![TopO()](TopO.png)

Bottom screen @ 4x, centered. Top screen @ 1x out of the viewport to the upper left.
**MDS_BotO(clip c, int "frame", int "frame2")**
**MDS_BotOA(clip c, int "frame", int "frame2")**
![BotO()](BotO.png)

Top screen @ 4x, centered. Bottom screen @ 1x overlayed lower right corner.
**MDS_TPIP(clip c, int "frame", int "frame2")**
**MDS_TPIPA(clip c, int "frame", int "frame2")**
![TPIP()](TPIP.png)

Bottom screen @ 4x, centered. Top screen @ 1x overlayed upper left corner.
**MDS_BPIP(clip c, int "frame", int "frame2")**
**MDS_BPIPA(clip c, int "frame", int "frame2")**
![BPIP()](BPIP.png)

Top screen @ 4x, left side of viewport. Bottom screen @ 1x, lower right corner.
**MDS_TopC(clip c, int "frame", int "frame2")**
**MDS_TopCA(clip c, int "frame", int "frame2")**
![TopC()](TopC.png)

Bottom screen @ 4x, right side. Top screen @ 1x, upper left corner.
**MDS_BotC(clip c, int "frame", int "frame2")**
**MDS_BotCA(clip c, int "frame", int "frame2")**
![BotC()](BotC.png)

## Side by Side

2x magnification. Top screen on left, Bottom on right.
**MDS_SBS(clip c, int "frame", int "frame2")**
**MDS_SBSA(clip c, int "frame", int "frame2")**
![SBS()](SBS.png)

Top screen on left @ 3x, Bottom on right @ 2x.
**MDS_SBSL(clip c, int "frame", int "frame2")**
**MDS_SBSLA(clip c, int "frame", int "frame2")**
![SBSL()](SBSL.png)

Top screen on left @ 2x, Bottom on right @ 3x.
**MDS_SBSR(clip c, int "frame", int "frame2")**
**MDS_SBSRA(clip c, int "frame", int "frame2")**
![SBSR()](SBSR.png)


## 'Book' style

3x magnification. Book mode (ie, rotated 90 degrees) with no gap. Set RightInstead to true to rotate clockwise.
**MDS_Book(clip c, int "frame", int "frame2", bool "RightInstead")**
**MDS_BookA(clip c, int "frame", int "frame2", bool "RightInstead")**
![Book()](Book.png)

3x magnification. Book mode (ie, rotated 90 degrees) with screens placed as far apart as they can be. Set RightInstead to true to rotate clockwise.
**MDS_BookCGap(clip c, int "frame", int "frame2", bool "RightInstead")**
**MDS_BookCGapA(clip c, int "frame", int "frame2", bool "RightInstead")**
![BookCGap()](BookCGap.png)

Book mode (ie, rotated 90 degrees) with screens with an effective gap of 92 (default) pixels. Set RightInstead to true to rotate clockwise.
**MDS_BookGap(clip c, int "frame", int "frame2", string "gap", bool "RightInstead")**
**MDS_BookGapA(clip c, int "frame", int "frame2", bool "RightInstead")**
![BookGap()](BookGap.png)

2x magnification, is effectively rotated VStack.
**MDS_Book_VStackScale(clip c, int "frame", int "frame2", bool "RightInstead")**
**MDS_Book_VStackScaleA(clip c, int "frame", int "frame2", bool "RightInstead")**
![Book_VStackScale()](Book_VStackScale.png)
