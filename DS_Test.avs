import("MDS.avsi")

# Load Test Footage
raw = ImageSource("DS_Test.png",0,10000,fps=60,pixel_type="RGB32").AudioDub(blankclip())
raw = raw.ChangeFPS(60)
# Test Audio: a 3 hz / 7 hz audio file used to check if there are audio desyncs (causes popping when tracking though)
#raw = audiodub(raw,wavsource("testaudio.wav").loop(116).fadeout(100))

# Create local variables to space out our transitions. We will have a transition every 200 frames.
fnum = 200
spacer = 200

# Set Layout Name display mode to true for the purposes of this test
global MDS_ShowLayoutName = True
# Ensure AFC matches what we want for this video. In this case that is a 1 second transition, therefore 60 frames.
MDS_SetAFC(60)
# Ensure we are using the Quality settings, as opposed to the Draft settings
MDS_QualitySettings()		#Use some higher quality transition effects
# Initialize our project as a DS project:
MDS_SetupDS(raw)

# Select an initial layout
MDS_SBS()

# Iterate through every layout
MDS_SBSLA(fnum)
fnum = fnum + spacer
MDS_SBSRA(fnum)
fnum = fnum + spacer
MDS_TopCA(fnum)
fnum = fnum + spacer
MDS_BPIPA(fnum,fnum + spacer)
fnum = fnum + spacer + spacer
MDS_BotCA(fnum)
fnum = fnum + spacer
MDS_TPIPA(fnum)
fnum = fnum + spacer
MDS_BotOA(fnum)
fnum = fnum + spacer
MDS_TopOA(fnum)
fnum = fnum + spacer
MDS_TopHA(fnum)
fnum = fnum + spacer
MDS_BotHA(fnum)
fnum = fnum + spacer
MDS_TopVA(fnum)
fnum = fnum + spacer
MDS_QuickBotA(fnum,fnum + spacer)
fnum = fnum + spacer + spacer
MDS_BotVA(fnum)
fnum = fnum + spacer
MDS_QuickTopA(fnum)
fnum = fnum + spacer
MDS_VStackA(fnum)
fnum = fnum + spacer
MDS_VStackGapA(fnum)
fnum = fnum + spacer

# Dissolve/Fade effects
MDS_DissolveToTop(fnum)
fnum = fnum + spacer
MDS_DissolveToBot(fnum)
fnum = fnum + spacer
MDS_FadeToTop(fnum)
fnum = fnum + spacer
MDS_FadeToBot(fnum)
fnum = fnum + spacer
MDS_VStackA(fnum)
fnum = fnum + spacer

# Book layouts
MDS_Book_VStackScaleA(fnum)
fnum = fnum + spacer
MDS_BookA(fnum)
fnum = fnum + spacer
MDS_BookCGapA(fnum)
fnum = fnum + spacer
MDS_BookGapA(fnum)
fnum = fnum + spacer

# Now start showing off:
MDS_VStackGapA(fnum)
fnum = fnum + spacer
MDS_BookA(fnum,RightInstead = TRUE)
fnum = fnum + spacer
MDS_SBSLA(fnum)
fnum = fnum + spacer
MDS_Book_VStackScaleA(fnum,RightInstead = TRUE)
fnum = fnum + spacer
MDS_Book_VStackScaleA(fnum,RightInstead = FALSE)
fnum = fnum + spacer
# Design a custom layout:
MDS_Custom_TargetData(MDS_A_2w,MDS_A_2h,MDS_A_2w,MDS_A_2h,	0,0,MDS_Wrk_w - MDS_A_2w,0,	180,180)
MDS_CustomA(fnum)
fnum = fnum + spacer
MDS_SBSA(fnum)
fnum = fnum + spacer

trim(0,fnum)

#Optional resize for when making webms/gifs
#LanczosResize(width()/2,height()/2)
ConvertToYV12()