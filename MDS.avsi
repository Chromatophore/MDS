# MDS
# This library provides a collection of easy to use functions to help generate Let's Play type videos from DS and 3DS footage.
# It also includes an animation engine that can generate inbetween frames for moving from one layout to another ('tweening').
# The output it creates is intended for use with Youtube, and as such will generate a video that will qualify for the HD pipeline.
# It expects input video in a fairly standard format, with the 2 screens stacked on top of one another.
# For a DS game, this will be 256x384. For a 3DS game, this will be 400x480, with the lower screen centered in its section (since it is only 320x240)
# A couple of png images are available that will show what a video should look like.

# Temporary Readme can be found here:       http://lpix.org/sslptest/index.php?id=10443

# Changelog:
# R5, big rewrite:
#Goals:
#	Done Divorce the Layouts from the Tweening
#	Done 50% Redo the work functions to support ease type functions along both vectors of movement
#	Done Integration of rotation into the tweening functions as standard
#	Done Use a 'better' rotation library as standard, considering 'rotate', has less of the uneeded features of zoom
#	Done Add 3DS support either via a fork for by neatening up my insane spam of functions. The main thing to do is to seperate the 'shouting at people' values when checking sizes or whatever?
#	Done Rename my clip position/size variables to be a bit more sensible
#	Done Improve the rescaling functions to be better behaved

# TO DO LIST:
# Done Automate MTwn_Recall process with MTwn_Auto_Recall
# Done Allow for setting temporary order overrides
# Done Change Rotation interpolater to find shortest rotational distance between two given values
# Done allow for picking output sizes between wide and 5x4
# Done Fix audio
# Done Fix video

# Revions 4:
# More stuff for R4 from YamiNoSenshi. Thanks YamiNoSenshi!
# Done: Added Vertical Mode, just call MDS_SetVerticalMode() And use MDS_Book or MDS_BookGap! Technically works with everything else but uses a 3x multiple - use after SetParams
# Done: Added transition effect to go from VertStack to... Vertstack rotated on its side? You probably want to call MDS_BookA afterwards. -
#	MDS_VStackToRotated and MDS_RotatedToVStack. They have an optional param to select which way to rotate which will be remembered across multiple calls.
# Done: Added 'step' params to resize and positioning function, in case this is useful for more advanced functions. Will just be an integer from 0 to 29.
# Done: Fixed resize methods for immediate function to match those used in animated (relevant to lower res videos)
# Done: Changed the way MDS_AnimFunc and MDS_PositionFunc get called, now they let you change the core animation that's at work, which lets you actually accomplish things by changing them, unlike previous attempts.
# Done: Added MDS_DraftSettings and MDS_QualitySettings, which are some presets for blockpreserve and resize filters so that people who don't actually want
#   to know every detail of this stupid overengineered system can get smoother (but slower to process) results

# Revision 3:  (# NB: original Rev 3 has typo, was line 322, has -MDS_QSzY instead of -MDS_QSzX )
# Got some ideas of stuff to add for R3 from Admiral H. Curtiss, and Captain Flame Guy, and the Tech Support Crowd helped a bit too
# Done: Fixed some stupid bugs with TopO and BottomO
# Done: Added in automated better sizing below 1x scale
# Done: Add 4th param to most 3 param calls to 'undo'
# Done: FlipFlop function?
# Done: Create functions that allow you to change additional filters
# Done: Add in functions for help with custom transitions

# Revision 2:
# Done: Have some way to have frame A drawn before frame B, should be pretty easy to do with an eval/default values
# Nope: Probably add some more examples?
# Done: Make a function to set the variables yourself and then call functions to perform them
# Done: Make some functions that make it easier to perform eg Fades/Dissolves without desyncing the two videos


###################################################
############# Variables and Constants #############
###################################################

###################################
# Debug Tools

# Attempts at debug functions: Displays data on frames during animations
global MDS_ShowDebug = False
# Displays the Layout name as a large subtitle on output:
global MDS_ShowLayoutName = False

###################################
# Ease, Rotation and Resize Functions

# Ease:
# This function converts a value from 0 to 1 to represent the ratio between the start/end points that the particular frame in the tweening should use
# EG just returning ratio would be linear interpolation between them.
global MTwn_GB_EaseFunction = "ratio = MTwn_SineInOut(ratio)"

global MTwn_RS_EaseFunction = ""
global MTwn_RT_EaseFunction = ""
global MTwn_PS_EaseFunction = ""

# Rotation:
# This is the filter that will be called for rotation (eg, with the rotate plugin)
# the params you have access to are called c (the clip) and r (an angle in degrees)
global MTwn_RotationPluginCall = "rotate(c,angle = r)"

# Resizing:
# These are used when we resize the videos by either eg 1x, 2x, 3x etc, or by 1.4, 2.6 etc
global MDS_Resize_IntegerFactor = "PointResize"
global MDS_Resize_NonIntFactor = "Spline36Resize"

###################################
# Processing Variables & Flags

# Input footage is multiplied up by MDS_BlockPreserve, in an attempt to preserve blockiness.
global MDS_BlockPreserve = 0

# This string is called to recall previous values for MTwn. It is now set to MTween's AutoRecall for simplicity.
global MDS_Recall_String = """
MTwn_AutoRecall()"""

# This variable stores the amount of times we should override the order
global MDS_UseOrderOverRide = 0
global MDS_StoredOrderOverride = ""

###################################
# Internal Processing Variables & Flags

# AFC variables, these should be identical, MDS_AFC is used for eg Fade/Dissolve effects.
global MDS_AFC = 60 	# Animation frame count for MDS
global MTwn_AFC = 60 	# Animation frame count for MTween

global MDS_RotatedToRight = false
global MDS_VStackGapGap = 92
global MDS_BookGapGap = 92

global MDS_LastFrame = 0

###################################
# Constants:
# These are the work space width/height setups

# Standard DS
# Constants for 5x4 and Widescreen
global MDS_Wrk_w_5x4 = 1280
global MDS_Wrk_w_wide = 1368

global MDS_Wrk_w = 1280
global MDS_Wrk_h = 768

# Screens are thes ame => Any
global MDS_A_4w = 1024
global MDS_A_4h = 768

global MDS_A_3w = 768
global MDS_A_3h = 576

global MDS_A_2w = 512
global MDS_A_2h = 384

global MDS_A_w = 256
global MDS_A_h = 192


global MDS_Border = 128

# The real sizes of these screens, useful for doing sneaky pixel math
global MDS_A_real_w = 256
global MDS_A_real_h = 192

# 3DS mode:
# Constants for 5x4 and Widescreen
global M3DS_Wrk_w_5x4 = 1600
global M3DS_Wrk_w_wide = 1708

global M3DS_Wrk_w = 1600
global M3DS_Wrk_h = 960

# The size of the screens at each magnification
global M3DS_T_4w = 1600
global M3DS_T_4h = 960

global M3DS_B_4w = 1280
global M3DS_B_4h = 960


global M3DS_T_3w = 1200
global M3DS_T_3h = 720

global M3DS_B_3w = 960
global M3DS_B_3h = 720


global M3DS_T_2w = 800
global M3DS_T_2h = 480

global M3DS_B_2w = 640
global M3DS_B_2h = 480


global M3DS_T_w = 400
global M3DS_T_h = 240

global M3DS_B_w = 320
global M3DS_B_h = 240


global M3DS_Border = 160

global M3DS_T_real_w = 400
global M3DS_T_real_h = 240
global M3DS_B_real_w = 320
global M3DS_B_real_h = 240




###################################
# And this just makes our video return something if we accidently view it
BlankClip(length=240, width=640, height=480, pixel_type="RGB32", fps=30, fps_denominator=1, audio_rate=44100, stereo=False, sixteen_bit=True, color=$000000)
Subtitle("This is MDS.avsi! Import this script into your AVS!")
Subtitle("Also, load your avi after you import, because this clip returned by the import line!",y = 50)


######################################################################
######################################################################
# Functions to set variables correctly

###################################
# SetAFC sets the Animation Frame Count to the specified value (ie, how many frames it takes for a transition to occur)
function MDS_SetAFC(int newAFC)
{
	global MDS_AFC = newAFC
	global MTwn_AFC = newAFC
}

###################################
# These two functions setup Draft or Quality modes
function MDS_DraftSettings()
{
	MDS_SetBlockPreserve(0)
	global MDS_Resize_IntegerFactor = "PointResize"
	global MDS_Resize_NonIntFactor = "PointResize"
}
function MDS_QualitySettings()
{
	MDS_SetBlockPreserve(4)
	global MDS_Resize_IntegerFactor = "PointResize"
	global MDS_Resize_NonIntFactor = "Spline36Resize"
}

###################################
# MDS_SetBlockPreserve sets the block multiplier for your videos
function MDS_SetBlockPreserve(int Factor)
{
	global MDS_BlockPreserve = Factor
}

###################################
# MDS_SetResizeFilters selects which resizing filters are used in which case
function MDS_SetResizeFilters(string "IntegerFactor", string "NonIntFactor")
{
	global MDS_Resize_IntegerFactor = Default(IntegerFactor,MDS_Resize_IntegerFactor)
	global MDS_Resize_NonIntFactor = Default(NonIntFactor,MDS_Resize_NonIntFactor)
}

###################################
# MDS_ChangeRotationWorker allows you to change the rotation worker if you need to use a different rotation plugin
function MDS_ChangeRotationWorker(string "Worker")
{
	global MTwn_RotationPluginCall = Default(Worker,MTwn_RotationPluginCall)
}

###################################
# MDS_ResetLastframe allows you to override the MDS_LastFrame variable, which is used in exception checking
function MDS_ResetLastframe()
{
	global MDS_LastFrame = 0
}

###################################
# MDS_SetupDS initialises MDS and MTwn for use with standard DS footage
function MDS_SetupDS(clip raw, bool "wide", int "blockpreserve", string "layout")
{
	layout = default(layout,"MDS_VStack()")
	blockpreserve = default(blockpreserve,MDS_BlockPreserve)
	wide = default(wide,false)

	global MDS_Wrk_w = wide == true ? MDS_Wrk_w_wide : MDS_Wrk_w_5x4

	top = intMDS_GetTop(raw)
	bot = intMDS_GetBot(raw)

	nan = blockpreserve > 1 ? eval("""
	MTwn_SetRaw("T",top.PointResize(top.width()*blockpreserve, top.height()*blockpreserve))
	MTwn_SetRaw("B",bot.PointResize(bot.width()*blockpreserve, bot.height()*blockpreserve))
	""") : eval("""
	MTwn_SetRaw("T",top)
	MTwn_SetRaw("B",bot)
	""")

	MTwn_SetRaw("Audio",raw.KillVideo())

	MTwn_SetupID("T")
	MTwn_SetupID("B")

	global MTwn_Order = "T,B"
	global MDS_StoredOrderOverride = "B,T"

	# Generate Base clip
	audiodubex(BlankClip(raw,width = MDS_Wrk_w,height = MDS_Wrk_h),raw)
	eval(layout)
}

###################################
# MDS_Setup3DS initialises MDS and MTwn for use with new 3DS footage
function MDS_Setup3DS(clip raw, bool "wide", int "blockpreserve", string "layout")
{
	layout = default(layout,"MDS_VStack()")
	blockpreserve = default(blockpreserve,MDS_BlockPreserve)
	wide = default(wide,false)

	global M3DS_Wrk_w = wide == true ? M3DS_Wrk_w_wide : M3DS_Wrk_w_5x4

	top = intM3DS_GetTop(raw)
	bot = intM3DS_GetBot(raw)

	nan = blockpreserve > 1 ? eval("""
	MTwn_SetRaw("T3D",top.PointResize(top.width()*blockpreserve, top.height()*blockpreserve))
	MTwn_SetRaw("B3D",bot.PointResize(bot.width()*blockpreserve, bot.height()*blockpreserve))
	""") : eval("""
	MTwn_SetRaw("T3D",top)
	MTwn_SetRaw("B3D",bot)
	""")

	MTwn_SetRaw("Audio",raw.KillVideo())

	MTwn_SetupID("T3D")
	MTwn_SetupID("B3D")

	global MTwn_Order = "T3D,B3D"
	global MDS_StoredOrderOverride = "B3D,T3D"

	# Generate Base clip
	audiodubex(BlankClip(raw,width = M3DS_Wrk_w,height = M3DS_Wrk_h),raw)
	eval(layout)
}

###################################
###################################
# Layout functions:

###################################
# Side by Side, even size
function intMDS_SBS()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - (2 * MDS_A_2w))/2),floor((MDS_Wrk_h - MDS_A_2h) / 2),		MDS_A_2w,MDS_A_2h,0,false)
	MTwn_SetTargets("B", round(MDS_Wrk_w / 2),floor((MDS_Wrk_h - MDS_A_2h) / 2),						MDS_A_2w,MDS_A_2h,0,false)

	MTWN_SetTargets("T3D", floor((M3DS_Wrk_w - (M3DS_T_2w + M3DS_B_2w)) / 2),round((M3DS_Wrk_h - M3DS_T_2h)/2), 			M3DS_T_2w,M3DS_T_2h, 0,false)
	MTWN_SetTargets("B3D", floor((M3DS_Wrk_w - (M3DS_T_2w + M3DS_B_2w)) / 2)+M3DS_T_2w,round((M3DS_Wrk_h - M3DS_B_2h)/2), 	M3DS_B_2w,M3DS_B_2h, 0,false)
}
function MDS_SBS(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBS()",false,frame,frame2)
}
function MDS_SBSA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBS()",true,frame,frame2)
}

###################################
# Side by Side, emphasis left
function intMDS_SBSL()
{
	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_3w - MDS_A_2w) / 2),floor((MDS_Wrk_h - MDS_A_3h) / 2),						MDS_A_3w,MDS_A_3h,0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w - MDS_A_3w - MDS_A_2w) / 2) + MDS_A_3w,floor((MDS_Wrk_h - MDS_A_2h) / 2),			MDS_A_2w,MDS_A_2h,0,false)

	# 3DS is TOO WIDE!
	remwidth = M3DS_Wrk_w - M3DS_T_3w
	remscale = float(remwidth) / M3DS_B_w

	MTWN_SetTargets("T3D", 0,round((M3DS_Wrk_h - M3DS_T_3h) / 2), 										M3DS_T_3w,M3DS_T_3h, 0,false)
	MTWN_SetTargets("B3D", M3DS_T_3w, round( (M3DS_Wrk_h - round(M3DS_B_h * remscale)) / 2), 			round(M3DS_B_w * remscale),round(M3DS_B_h * remscale), 0,false)
}
function MDS_SBSL(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBSL()",false,frame,frame2)
}
function MDS_SBSLA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBSL()",true,frame,frame2)
}

###################################
# Side by Side, emphasis right
function intMDS_SBSR()
{
	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_3w - MDS_A_2w) / 2),floor((MDS_Wrk_h - MDS_A_2h) / 2),						MDS_A_2w,MDS_A_2h,0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w - MDS_A_3w - MDS_A_2w) / 2) + MDS_A_2w,floor((MDS_Wrk_h - MDS_A_3h) / 2),			MDS_A_3w,MDS_A_3h,0,false)

	# 3DS is TOO WIDE!
	remwidth = M3DS_Wrk_w - M3DS_B_3w
	remscale = float(remwidth) / M3DS_T_w

	MTWN_SetTargets("T3D", 0,round( (M3DS_Wrk_h - round(M3DS_T_h * remscale)) / 2), 					round(M3DS_T_w * remscale),round(M3DS_T_h * remscale), 0,false)
	MTWN_SetTargets("B3D", M3DS_Wrk_w - M3DS_B_3w, round((M3DS_Wrk_h - M3DS_B_3h) / 2), 				M3DS_B_3w, M3DS_B_3h, 0,false)
}
function MDS_SBSR(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBSR()",false,frame,frame2)
}
function MDS_SBSRA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_SBSR()",true,frame,frame2)
}

###################################
# Top screen at maximum size, Bottom screen in the corner/offscreen
function intMDS_TopC()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w - MDS_A_w) / 2),0, 								MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w - MDS_A_w) / 2) + MDS_A_4w ,MDS_Wrk_h-MDS_A_h, 	MDS_A_w,MDS_A_h, 0,false)

	# In most cases, the top is so wide it will fill the whole top screen, so, I guess we might as well just center it?
	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2), 0,  									M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2) + M3DS_T_4w, M3DS_Wrk_h - M3DS_B_h, 		M3DS_B_w, M3DS_B_h, 0,false)
}
function MDS_TopC(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopC()",false,frame,frame2)
}
function MDS_TopCA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopC()",true,frame,frame2)
}

###################################
# Bottom screen at maximum size, Top screen in the corner/offscreen
function intMDS_BotC()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w - MDS_A_w) / 2),0, 								MDS_A_w,MDS_A_h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w - MDS_A_w) / 2) + MDS_A_w ,0, 						MDS_A_4w,MDS_A_4h, 0,false)

	# Ensure we always at least show the bottom only? Eh, I don't think anyone will use this layouts for 3DS
	# Clarification: If someone made the Workspace narrower, this would not be laid out as advertised
	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_w - M3DS_B_4w) / 2), 0,  							M3DS_T_w,M3DS_T_h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_T_w - M3DS_B_4w) / 2) + M3DS_T_w, 0, 				M3DS_B_4w, M3DS_B_4h, 0,false)
}
function MDS_BotC(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotC()",false,frame,frame2)
}
function MDS_BotCA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotC()",true,frame,frame2)
}

###################################
# Top screen at maximum size, bottom screen shrunk down + offscreen
function intMDS_TopO()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w) / 2),0, 						MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", MDS_Wrk_w,MDS_Wrk_h-MDS_A_h, 								MDS_A_w,MDS_A_h, 0,false)

	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2), 0,  				M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", M3DS_Wrk_w, M3DS_Wrk_h - M3DS_B_h, 						M3DS_B_w, M3DS_B_h, 0,false)
}
function MDS_TopO(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopO()",false,frame,frame2)
}
function MDS_TopOA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopO()",true,frame,frame2)
}

###################################
# Bottom screen at maximum size, top screen shrunk down + offscreen
function intMDS_BotO()
{
	MTwn_SetTargets("T", -MDS_A_w,0, 												MDS_A_w,MDS_A_h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w) / 2),0, 						MDS_A_4w,MDS_A_4h, 0,false)

	MTWN_SetTargets("T3D", -M3DS_T_w, 0,  											M3DS_T_w,M3DS_T_h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_B_4w) / 2), 0,					M3DS_B_4w, M3DS_B_4h, 0,false)
}
function MDS_BotO(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotO()",false,frame,frame2)
}
function MDS_BotOA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotO()",true,frame,frame2)
}

###################################
# Top screen at maximum size, Bottom screen at Max side, horizontally displaced
function intMDS_TopH()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w) / 2) + MDS_A_4w,0, 			MDS_A_4w,MDS_A_4h, 0,false)

	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2), 0,  				M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2) + M3DS_T_4w, 0,		M3DS_B_4w,M3DS_B_4h, 0,false)
}
function MDS_TopH(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopH()",false,frame,frame2)
}
function MDS_TopHA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopH()",true,frame,frame2)
}

###################################
# Bottom screen at maximum size, Top screen at Max side, horizontally displaced
function intMDS_BotH()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w) / 2) - MDS_A_4w,0,			MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w) / 2),0, 						MDS_A_4w,MDS_A_4h, 0,false)

	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_B_4w) / 2) - M3DS_T_4w, 0,  	M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_B_4w) / 2), 0,					M3DS_B_4w,M3DS_B_4h, 0,false)
}
function MDS_BotH(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotH()",false,frame,frame2)
}
function MDS_BotHA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotH()",true,frame,frame2)
}

###################################
# Top screen at maximum size, Bottom screen at Max side, vertically displaced
function intMDS_TopV()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w) / 2),MDS_A_4h, 				MDS_A_4w,MDS_A_4h, 0,false)

	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2), 0,  				M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_B_4w) / 2), M3DS_T_4h,			M3DS_B_4w,M3DS_B_4h, 0,false)
}
function MDS_TopV(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopV()",false,frame,frame2)
}
function MDS_TopVA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TopV()",true,frame,frame2)
}

###################################
# Bottom screen at maximum size, Top screen at Max side, vertically displaced
function intMDS_BotV()
{
	MTwn_SetTargets("T", round((MDS_Wrk_w - MDS_A_4w) / 2),-MDS_A_4h,				MDS_A_4w,MDS_A_4h, 0,false)
	MTwn_SetTargets("B", round((MDS_Wrk_w - MDS_A_4w) / 2),0, 						MDS_A_4w,MDS_A_4h, 0,false)

	MTWN_SetTargets("T3D", round((M3DS_Wrk_w - M3DS_T_4w) / 2), -M3DS_T_4h, 		M3DS_T_4w,M3DS_T_4h, 0,false)
	MTWN_SetTargets("B3D", round((M3DS_Wrk_w - M3DS_B_4w) / 2), 0,					M3DS_B_4w,M3DS_B_4h, 0,false)
}
function MDS_BotV(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotV()",false,frame,frame2)
}
function MDS_BotVA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BotV()",true,frame,frame2)
}

###################################
# Both screens vertically stacked with no gap
function intMDS_VStack()
{
	MTwn_SetTargets("T", floor((MDS_Wrk_w - MDS_A_2w) / 2),0, 						MDS_A_2w,MDS_A_2h, 0,false)
	MTwn_SetTargets("B", floor((MDS_Wrk_w - MDS_A_2w) / 2),MDS_A_2h, 				MDS_A_2w,MDS_A_2h, 0,false)

	MTWN_SetTargets("T3D", floor((M3DS_Wrk_w - M3DS_T_2w) / 2),0, 					M3DS_T_2w,M3DS_T_2h, 0,false)
	MTWN_SetTargets("B3D", floor((M3DS_Wrk_w - M3DS_B_2w) / 2),M3DS_T_2h, 			M3DS_B_2w,M3DS_B_2h, 0,false)
}
function MDS_VStack(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_VStack()",false,frame,frame2)
}
function MDS_VStackA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_VStack()",true,frame,frame2)
}

###################################
# Both screens vertically stacked with a gap
function intMDS_VStackGap()
{
	# This is adapted from a function from SA poster YamiNoSenshi
	TempGap = MDS_VStackGapGap

	totallines = MDS_A_real_h * 2 + TempGap
	ratio = float(MDS_A_real_h) / float(totallines)

	New_h = floor(MDS_Wrk_h * ratio)
	New_w = round((float(New_h) * 4) / 3)

	MTwn_SetTargets("T", floor((MDS_Wrk_w - New_w) / 2),0, 							New_w,New_h, 0,false)
	MTwn_SetTargets("B", floor((MDS_Wrk_w - New_w) / 2),MDS_Wrk_h - New_h, 			New_w,New_h, 0,false)

	# Pixel gap in 3DS doesn't seem to be as much of 'a thing' as it was for the DS. The gap is slightly less than the DS, possibly very much so for eg the 2DS
	# But we also have a higher res. Turns out the answer is still ~92

	totallines = M3DS_T_real_h + M3DS_B_real_h + TempGap

	ratio = float(M3DS_T_real_h) / float(totallines)
	New_h = floor(M3DS_Wrk_h * ratio)
	New_w = round((float(New_h)) * (float(M3DS_T_real_w) / M3DS_T_real_h))

	MTwn_SetTargets("T3D", floor((M3DS_Wrk_w - New_w) / 2),0, 						New_w,New_h, 0,False)

	ratio = float(M3DS_B_real_h) / float(totallines)
	New_h = floor(M3DS_Wrk_h * ratio)
	New_w = round((float(New_h)) * (float(M3DS_B_real_w) / M3DS_B_real_h))

	MTwn_SetTargets("B3D", floor((M3DS_Wrk_w - New_w) / 2), M3DS_Wrk_h - New_h, 	New_w,New_h, 0,False)
}
function MDS_VStackGap(clip c, string "gap")
{
	gap = default(gap,string(MDS_VStackGapGap))
	global MDS_VStackGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_VStackGap()",false,0)
}
function MDS_VStackGapA(clip c, string "gap")
{
	gap = default(gap,string(MDS_VStackGapGap))
	global MDS_VStackGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_VStackGap()",true,0)
}
function MDS_VStackGap(clip c, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_VStackGapGap))
	global MDS_VStackGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_VStackGap()",false,frame,frame2)
}
function MDS_VStackGapA(clip c, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_VStackGapGap))
	global MDS_VStackGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_VStackGap()",true,frame,frame2)
}

###################################
# Places the DS in Book mode (rotated so the screens are portrait)
function intMDS_Book()
{
	# Fill the screen with 3x mag rotated images!

	# NB for sanity's sake I'm going to use midpoint coords, because this is a rotated output. As such, we provide the center point of the output to simplify
	# what this would be like for our primitive human minds.

	rotation = MDS_RotatedToRight == true ? 90 : -90

	# Switch which screen is on which side for rotated right settings
	val1 = MDS_RotatedToRight == true ? "B" : "T"
	val2 = MDS_RotatedToRight == true ? "T" : "B"

	MTwn_SetTargets(val1, floor((MDS_Wrk_w - MDS_A_3h) / 2),floor(MDS_Wrk_h / 2), 	MDS_A_3w,MDS_A_3h, rotation,true)
	MTwn_SetTargets(val2, floor((MDS_Wrk_w + MDS_A_3h) / 2),floor(MDS_Wrk_h / 2), 	MDS_A_3w,MDS_A_3h, rotation,true)


	# At most we can fit the top screen in vertically?
	magfactor = float(M3DS_Wrk_h) / M3DS_T_w

	v_dir = MDS_RotatedToRight == true ? -1 : 1

	tw = round(float(M3DS_T_w) * magfactor)
	th = round(float(M3DS_T_h) * magfactor)
	bw = round(float(M3DS_B_w) * magfactor)
	bh = round(float(M3DS_B_h) * magfactor)

	MTwn_SetTargets("T3D", round((M3DS_Wrk_w - v_dir * th) / 2),floor(M3DS_Wrk_h / 2), 					tw,th, rotation,true)
	MTwn_SetTargets("B3D", round((M3DS_Wrk_w + v_dir * bh) / 2),floor(M3DS_Wrk_h / 2), 					bw,bh, rotation,true)
}
function MDS_Book(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book()",false,0)
}
function MDS_BookA(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book()",true,0)
}
function MDS_Book(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book()",false,frame,frame2)
}
function MDS_BookA(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book()",true,frame,frame2)
}

###################################
# Places the DS in Book mode (rotated so the screens are portrait) with a gap between the screens
function intMDS_BookGap()
{
	# This is adapted from a function from SA poster YamiNoSenshi

	TempGap = MDS_BookGapGap

	totallines = MDS_A_real_h * 2 + TempGap
	ratio = float(MDS_A_real_h) / float(totallines)

	# So if gap is too small, this will accidently zoom into the content, so, if ratio * height > three height, just do it normally?

	New_h = floor(MDS_Wrk_w * ratio)
	New_w = round((New_h * 4) / 3)

	rotation = MDS_RotatedToRight == true ? 90 : -90

	# Switch which screen is on which side for rotated right settings
	val1 = MDS_RotatedToRight == true ? "B" : "T"
	val2 = MDS_RotatedToRight == true ? "T" : "B"

	# Also remember, center coords again!

	# If these would be oversized due to eg having no gap, catch this and don't zoom in!
	l = (New_w > MDS_Wrk_h) ? eval("""
		# Scale the gap up to our magnification.
		ScaledGap = floor(float(TempGap) * (float(MDS_A_3h) / float(MDS_A_real_h)))	# I guess this is in case we're not doing 3x

		MTwn_SetTargets(val1, round((MDS_Wrk_w - ScaledGap - MDS_A_3w) / 2),MDS_Wrk_h / 2, 				MDS_A_3w,MDS_A_3h, rotation,true)
		MTwn_SetTargets(val2, round((MDS_Wrk_w + ScaledGap + MDS_A_3w) / 2),MDS_Wrk_h / 2, 				MDS_A_3w,MDS_A_3h, rotation,true)

	""") : eval ("""
		# Otherwise scale them down

		MTwn_SetTargets(val1, round((0 + New_h) / 2),MDS_Wrk_h / 2, 									New_w,New_h, rotation,true)
		MTwn_SetTargets(val2, MDS_Wrk_w - round((New_h) / 2),MDS_Wrk_h / 2, 							New_w,New_h, rotation,true)
	""")

	# At most we can fit the top screen in vertically?
	# As a result, things are always going to fit in any likely circumstance that we'll do.
	magfactor = float(M3DS_Wrk_h) / M3DS_T_w

	v_dir = MDS_RotatedToRight == true ? -1 : 1

	tw = round(float(M3DS_T_w) * magfactor)
	th = round(float(M3DS_T_h) * magfactor)
	bw = round(float(M3DS_B_w) * magfactor)
	bh = round(float(M3DS_B_h) * magfactor)

	spacer = round(float(TempGap) * magfactor)

	MTwn_SetTargets("T3D", round((M3DS_Wrk_w - v_dir * th - v_dir * spacer) / 2),floor(M3DS_Wrk_h / 2), 			tw,th, rotation,true)
	MTwn_SetTargets("B3D", round((M3DS_Wrk_w + v_dir * bh + v_dir * spacer) / 2),floor(M3DS_Wrk_h / 2), 			bw,bh, rotation,true)
}
function MDS_BookGap(clip c, string "gap", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	gap = default(gap,string(MDS_BookGapGap))
	global MDS_BookGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_BookGap()",false,0)
}
function MDS_BookGapA(clip c, string "gap", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	gap = default(gap,string(MDS_BookGapGap))
	global MDS_BookGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_BookGap()",true,0)
}
function MDS_BookGap(clip c, int frame, int "frame2", string "gap", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	gap = default(gap,string(MDS_BookGapGap))
	global MDS_BookGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_BookGap()",false,frame,frame2)
}
function MDS_BookGapA(clip c, int frame, int "frame2", string "gap", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	gap = default(gap,string(MDS_BookGapGap))
	global MDS_BookGapGap = Value(gap)
	MDS_SameCode_Root(c,"intMDS_BookGap()",true,frame,frame2)
}

###################################
# Places the DS in Book mode (rotated so the screens are portrait) with a gap such that they extend (only) to the edges of the workspace
function intMDS_BookCGap()
{
	# NB for sanity's sake I'm going to use midpoint coords, because this is a rotated output. As such, we provide the center point of the output to simplify
	# what this would be like for our primitive human minds.

	rotation = MDS_RotatedToRight == true ? 90 : -90

	# Switch which screen is on which side for rotated right settings
	val1 = MDS_RotatedToRight == true ? "B" : "T"
	val2 = MDS_RotatedToRight == true ? "T" : "B"

	MTwn_SetTargets(val1, floor((MDS_A_3h) / 2),floor(MDS_Wrk_h / 2), 				MDS_A_3w,MDS_A_3h, rotation,true)
	MTwn_SetTargets(val2, MDS_Wrk_w - floor(MDS_A_3h / 2),floor(MDS_Wrk_h / 2), 	MDS_A_3w,MDS_A_3h, rotation,true)


	# At most we can fit the top screen in vertically?
	magfactor = float(M3DS_Wrk_h) / M3DS_T_w

	v_mult = MDS_RotatedToRight == true ? 1 : 0
	v_dir = MDS_RotatedToRight == true ? -1 : 1

	tw = round(float(M3DS_T_w) * magfactor)
	th = round(float(M3DS_T_h) * magfactor)
	bw = round(float(M3DS_B_w) * magfactor)
	bh = round(float(M3DS_B_h) * magfactor)

	MTwn_SetTargets("T3D", M3DS_Wrk_w * v_mult + v_dir * (th / 2),floor(M3DS_Wrk_h / 2), 				tw,th, rotation,true)
	MTwn_SetTargets("B3D", M3DS_Wrk_w * (1 - v_mult) - v_dir * (bh / 2),floor(M3DS_Wrk_h / 2), 			bw,bh, rotation,true)
}
function MDS_BookCGap(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_BookCGap()",false,0)
}
function MDS_BookCGapA(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_BookCGap()",true,0)
}
function MDS_BookCGap(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_BookCGap()",false,frame,frame2)
}
function MDS_BookCGapA(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_BookCGap()",true,frame,frame2)
}

###################################
# Places the DS in Book mode like all the others, with the screns the same size as they would be in a vstack (so vstack to this is a smooth rotation without resizing)
function intMDS_Book_VStackScale()
{
	# NB for sanity's sake I'm going to use midpoint coords, because this is a rotated output. As such, we provide the center point of the output to simplify
	# what this would be like for our primitive human minds.

	rotation = MDS_RotatedToRight == true ? 90 : -90

	# Switch which screen is on which side for rotated right settings
	val1 = MDS_RotatedToRight == true ? "B" : "T"
	val2 = MDS_RotatedToRight == true ? "T" : "B"

	MTwn_SetTargets(val1, floor((MDS_Wrk_w - MDS_A_2h) / 2),floor(MDS_Wrk_h / 2), 	MDS_A_2w,MDS_A_2h, rotation,true)
	MTwn_SetTargets(val2, floor((MDS_Wrk_w + MDS_A_2h) / 2),floor(MDS_Wrk_h / 2), 	MDS_A_2w,MDS_A_2h, rotation,true)

	# I really don't think we need this for 3DS but whatever...

	# At most we can fit the top screen in vertically?

	v_dir = MDS_RotatedToRight == true ? -1 : 1

	MTwn_SetTargets("T3D", round((M3DS_Wrk_w - v_dir * M3DS_T_2h) / 2),floor(M3DS_Wrk_h / 2), 			M3DS_T_2w,M3DS_T_2h, rotation,true)
	MTwn_SetTargets("B3D", round((M3DS_Wrk_w + v_dir * M3DS_B_2h) / 2),floor(M3DS_Wrk_h / 2), 			M3DS_B_2w,M3DS_B_2h, rotation,true)
}
function MDS_Book_VStackScale(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book_VStackScale()",false,0)
}
function MDS_Book_VStackScaleA(clip c, bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book_VStackScale()",true,0)
}
function MDS_Book_VStackScale(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book_VStackScale()",false,frame,frame2)
}
function MDS_Book_VStackScaleA(clip c, int frame, int "frame2", bool "RightInstead")
{
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	MDS_SameCode_Root(c,"intMDS_Book_VStackScale()",true,frame,frame2)
}

###################################
# Slides the lower screen over the Top screen
function intMDS_QuickBot()
{
	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h,	0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h,	0,false)

	MTwn_SetTargets("T3D",round((M3DS_Wrk_w - M3DS_T_4w) / 2),0,					M3DS_T_4w,M3DS_T_4h,	0,false)
	MTwn_SetTargets("B3D",round((M3DS_Wrk_w - M3DS_B_4w) / 2),0,					M3DS_B_4w,M3DS_B_4h,	0,false)
}
function MDS_QuickBot(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_QuickBot()",false,frame,frame2)
}
function MDS_QuickBotA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_QuickBot()",true,frame,frame2)
}

###################################
# Slides the upper screen over the bottom screen
function intMDS_QuickTop()
{
	# Set MDS_UseOrderOverRide to 2, meaning the inward and outward transition will be drawn in the Override order
	global MDS_UseOrderOverRide = 2

	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h,	0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w - MDS_A_4w) / 2),0,						MDS_A_4w,MDS_A_4h,	0,false)

	MTwn_SetTargets("T3D",round((M3DS_Wrk_w - M3DS_T_4w) / 2),0,					M3DS_T_4w,M3DS_T_4h,	0,false)
	MTwn_SetTargets("B3D",round((M3DS_Wrk_w - M3DS_B_4w) / 2),0,					M3DS_B_4w,M3DS_B_4h,	0,false)
}
function MDS_QuickTop(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_QuickTop()",false,frame,frame2)
}
function MDS_QuickTopA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_QuickTop()",true,frame,frame2)
}

###################################
# Brings the bottom screen is as a picture in picture
function intMDS_BPIP()
{
	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_4w) / 2),0,											MDS_A_4w,MDS_A_4h,	0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w + MDS_A_4w) / 2) - MDS_A_w,MDS_Wrk_h - MDS_A_h,				MDS_A_w,MDS_A_h,	0,false)

	MTwn_SetTargets("T3D",round((M3DS_Wrk_w - M3DS_T_4w) / 2),0,										M3DS_T_4w,M3DS_T_4h,	0,false)
	MTwn_SetTargets("B3D",round((M3DS_Wrk_w + M3DS_T_4w) / 2) - M3DS_B_w,M3DS_Wrk_h - M3DS_B_h,			M3DS_B_w,M3DS_B_h,	0,false)
}
function MDS_BPIP(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BPIP()",false,frame,frame2)
}
function MDS_BPIPA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_BPIP()",true,frame,frame2)
}

###################################
# Brings the top screen is as a picture in picture
function intMDS_TPIP()
{
	# Set MDS_UseOrderOverRide to 2, meaning the inward and outward transition will be drawn in the Override order
	global MDS_UseOrderOverRide = 2

	MTwn_SetTargets("T",round((MDS_Wrk_w - MDS_A_4w) / 2),0,											MDS_A_w,MDS_A_h,	0,false)
	MTwn_SetTargets("B",round((MDS_Wrk_w - MDS_A_4w) / 2),0,											MDS_A_4w,MDS_A_4h,	0,false)

	MTwn_SetTargets("T3D",round((M3DS_Wrk_w - M3DS_B_4w) / 2),0,										M3DS_T_w,M3DS_T_h,	0,false)
	MTwn_SetTargets("B3D",round((M3DS_Wrk_w - M3DS_B_4w) / 2),0,										M3DS_B_4w,M3DS_B_4h,	0,false)
}
function MDS_TPIP(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TPIP()",false,frame,frame2)
}
function MDS_TPIPA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"intMDS_TPIP()",true,frame,frame2)
}






###################################
# Used to define custom layouts
function MDS_Custom_TargetData(int Top_w,int Top_h,int Bot_w, int Bot_h, int Top_x, int Top_y, int Bot_x, int Bot_y, int "Top_r", int "Bot_r", bool "Top_Cent", bool "Bot_Cent")
{
	MDS_CTD_DS(		Top_w,Top_h,	Bot_w,Bot_h,	Top_x,Top_y,	Bot_x,Bot_y,	Top_r,Bot_r,	Top_Cent,Bot_Cent)
	# Most likely, people will only be using one or the other. If not, they can call MDS_CTD_DS & MDS_CTD_3DS seperately
	MDS_CTD_3DS(	Top_w,Top_h,	Bot_w,Bot_h,	Top_x,Top_y,	Bot_x,Bot_y,	Top_r,Bot_r,	Top_Cent,Bot_Cent)
}
function MDS_CTD_DS(int Top_w,int Top_h,int Bot_w, int Bot_h, int Top_x, int Top_y, int Bot_x, int Bot_y, int "Top_r", int "Bot_r", bool "Top_Cent", bool "Bot_Cent")
{
	Top_r = default(Top_r,0)
	Bot_r = default(Bot_r,0)

	Top_Cent = default(Top_Cent,false)
	Bot_Cent = default(Bot_Cent,false)

	MTwn_SetTargets("T", Top_x,Top_y, Top_w,Top_h, Top_r,Top_Cent)
	MTwn_SetTargets("B", Bot_x,Bot_y, Bot_w,Bot_h, Bot_r,Bot_Cent)
}
function MDS_CTD_3DS(int Top_w,int Top_h,int Bot_w, int Bot_h, int Top_x, int Top_y, int Bot_x, int Bot_y, int "Top_r", int "Bot_r", bool "Top_Cent", bool "Bot_Cent")
{
	Top_r = default(Top_r,0)
	Bot_r = default(Bot_r,0)

	Top_Cent = default(Top_Cent,false)
	Bot_Cent = default(Bot_Cent,false)

	MTwn_SetTargets("T3D", Top_x,Top_y, Top_w,Top_h, Top_r,Top_Cent)
	MTwn_SetTargets("B3D", Bot_x,Bot_y, Bot_w,Bot_h, Bot_r,Bot_Cent)
}
function MDS_Custom(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"#      Custom()",false,frame,frame2)
}
function MDS_CustomA(clip c, int "frame", int "frame2")
{
	frame = default(frame,0)
	MDS_SameCode_Root(c,"#      Custom()",true,frame,frame2)
}

###################################
# Dissolve transition wrapper
function MDS_Dissolve(clip c, int frame, string layout)
{
	# Perform frame # exception check
	MDS_ExceptionCheck(c,frame)

	# Extract audio to be retained
	aud = killvideo(c)
	# Remove audio from video to prevent needless work
	c = killaudio(c)

	# Generate the outcome layout
	try
	{
		outcome = Eval(layout + "(c)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably) (""" + layout + """)
""" + err_msg)
	}

	# Attach start to outcome
	Trim(c,0,frame - 1) + Dissolve(trim(c,frame,frame + MDS_AFC), trim(outcome,frame + 1,0),MDS_AFC)
	audiodubex(aud)
}

function MDS_DissolveToBot(clip c, int frame, string "layout")
{
	layout = Default(layout, "MDS_BotV")
	MDS_Dissolve(c, frame, layout)
}
function MDS_DissolveToTop(clip c, int frame, string "layout")
{
	layout = Default(layout, "MDS_TopV")
	MDS_Dissolve(c, frame, layout)
}

###################################
# Fade transition wrapper
function MDS_Fade(clip c, int frame, string layout, bool "fadeaudio")
{
	MDS_ExceptionCheck(c,frame)
	fadeaudio = Default(fadeaudio, false)

	# Extract audio to be retained
	aud = killvideo(c)
	# Retain audio for the purposes of fadeaudio!
		#c = killaudio(c)

	try
	{
		outcome = Eval(layout + "(c)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably) (""" + layout + """)
""" + err_msg)
	}

	k = floor(MDS_AFC/2)

	Trim(c,0,frame - 1) + FadeOut(trim(c,frame,frame + k),k) + FadeIn(trim(outcome,frame + k + 3,0),k)
	return (fadeaudio == false) ? audiodubex(last,aud) : last
}

###################################
# Fade transition wrapper with 2x AFC period
function MDS_LongFade(clip c, int frame, string layout, bool "fadeaudio")
{
	# Test both Frame and Frame + AFC, as this takes up 2x AFC to perform
	MDS_ExceptionCheck(c,frame)
	MDS_ExceptionCheck(c,frame+MDS_AFC)
	fadeaudio = Default(fadeaudio, false)

	# Extract audio to be retained
	aud = killvideo(c)
	# Retain audio for the purposes of fadeaudio!
		#c = killaudio(c)

	try
	{
		outcome = Eval(layout + "(c)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably) (""" + layout + """)
""" + err_msg)
	}

	k = floor(MDS_AFC)

	Trim(c,0,frame - 1) + FadeOut(trim(c,frame,frame + k),k) + FadeIn(trim(outcome,frame + k + 3,0),k)
	return (fadeaudio == false) ? AudioDubex(last,aud) : last
}

function MDS_FadeToBot(clip c, int frame, string "layout", bool "fadeaudio")
{
	layout = Default(layout, "MDS_BotV")
	fadeaudio = Default(fadeaudio, false)
	MDS_Fade(c,frame,layout,fadeaudio)
}
function MDS_FadeToTop(clip c, int frame, string "layout", bool "fadeaudio")
{
	layout = Default(layout, "MDS_TopV")
	fadeaudio = Default(fadeaudio, false)
	MDS_Fade(c,frame,layout,fadeaudio)
}

###################################
# Wrapper for custom transition
function MDS_CustomTransition(clip c, int frame, string layout, string funcname)
{
	MDS_ExceptionCheck(c,frame)

	# Extract audio to be retained
	aud = killvideo(c)
	# Retain audio for the purposes of fadeaudio!
	c = killaudio(c)

	try
	{
		outcome = Eval(layout + "(c)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably) (""" + layout + """)
""" + err_msg)
	}

	try
	{
		l = Eval(funcname + "(trim(c,frame,frame + MDS_AFC), trim(outcome,frame+1,0),MDS_AFC)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided transition function! (probably) (""" + funcname + """)
""" + err_msg)
	}

	Trim(c,0,frame - 1) + l
	audiodubex(last,aud)
}

###################################
# Recursive alternating function
function MDS_flipflop(clip c, clip raw, string func1, string func2, int f1, int "f2", \
int "f3", int "f4", int "f5", int "f6",\
int "f7", int "f8", int "f9", int "f10",\
int "f11", int "f12", int "f13", int "f14",\
int "f15", int "f16", int "f17", int "f18",\
int "f19", int "f20", int "f21", int "f22",\
int "f23", int "f24", int "f25", int "f26",\
int "f27", int "f28", int "f29", int "f30",\
int "f31", int "f32", int "f33", int "f34",\
int "f35", int "f36", int "f37", int "f38",\
int "f39", int "f40", int "f41", int "f42")
{
		f2 = Default(f2,-100)
		f3 = Default(f3,-100)
		f4 = Default(f4,-100)

		r = Eval(func1 + "(c,raw,f1)")
		r = (f2 > -100) ? Eval(func2 + "(r,raw,f2)") : r

		i = (f3 > -100) ? Eval("""
			r = MDS_flipflop(r,raw,func1,func2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,\
			f13,f14,f15,f16,f17,f18,f19,f20,f21,f22,f23,f24,f25,f26,\
			f27,f28,f29,f30,f31,f32,f33,f34,f35,f36,f37,f38,f39,f40,f41,f42)
			""") : Eval("")

		return r
}


###################################
###################################
# Internal functions

###################################
# The root code that decides which MTwn functions to call and how to organise all of our basic goings on
function MDS_SameCode_Root(clip c, string LayoutName, bool IsAnimated, int frame, int "frame2")
{
	# New samecode function to work with MTween, which manages raw footage based on frame
	# Where as before, we would trim raw and whittle down to simpler functions, we much now do the reverse: All functions will lead to here

	# 1) Check the Frame vs Lastcall is good:
	l = IsAnimated == true ? MDS_ExceptionCheck(c,frame) : MDS_ExceptionCheck(c)

	# 2) Forget about frame2 for now and simply use recursion!
	frame2 = default(frame2,-100)

	# 3) Apply the layout that has been provided, if we have been provided one (eg custom will not provide one, although it will probably supply #Custom or something
	try {
		l = LayoutName != "" ? eval(LayoutName) : 1
	} catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably) (""" + LayoutName + """)
""" + err_msg)
	}

	# 4) Obtain OrderOverride value
	OrderOver1 = UnDefined()
	OrderOver2 = UnDefined()
	l = MDS_UseOrderOverRide > 1 ? eval("OrderOver2 = MDS_StoredOrderOverride") : 0
	l = MDS_UseOrderOverRide > 0 ? eval("""
	OrderOver1 = MDS_StoredOrderOverride
	global MDS_UseOrderOverRide = MDS_UseOrderOverRide - 1
	""") : 0

	# 5) If it's animated, use Go_A, if it's not, use Go_I
	c = IsAnimated == true ? MTwn_Go_A(c,frame,OrderOver1,OrderOver2) : MTwn_Go_I(c,frame,OrderOver1)

	# 6) Apply Subs for layout name if required
	c = MDS_ShowLayoutName == true ? c.Subtitle(midstr(LayoutName,8),8,8,frame,size = 72) : c

	# 7) If frame2 is defined, call this function again with that frame defined instead, and the recall string instead of the layout
	c = frame2 != -100 ? MDS_SameCode_Root(c,MDS_Recall_String,IsAnimated,frame2) : c

	# Return!
	return c
}

###################################
# Cropping functions for standard footage for DS and 3DS screens
function intMDS_GetTop(clip c)
{
	crop(c,0,0,0,MDS_A_real_h)
}
function intMDS_GetBot(clip c)
{
	crop(c,0,MDS_A_real_h,0,0)
}

function intM3DS_GetTop(clip c)
{
	crop(c,0,0,0,M3DS_T_real_h)
}
function intM3DS_GetBot(clip c)
{
	crop(c,40,M3DS_T_real_h,M3DS_B_real_w,0)
}

###################################
# Exception Checks:
Function MDS_ExceptionCheck(clip c)
{
	# no longer perform frame size check, as we support any size frame sizes now I guess
	#Assert(width(raw) == MDS_basesizeX, "MDS Error: Raw clip not " + string(MDS_basesizeX) + " pixels wide")
	#Assert(height(raw) == 2 * MDS_basesizeY, "MDS Error: Raw clip not " + string(MDS_basesizeY) + " pixels high")
}
Function MDS_ExceptionCheck(clip c, int frame)
{
	MDS_ExceptionCheck(c)
	Assert(frame >= MDS_LastFrame, "MDS Error: Frame " + string(frame) + " is smaller than lastframe+MDS_AFC (" + string(MDS_LastFrame) + ") - call MDS_ResetLastframe() if not an error")
	global MDS_LastFrame = frame + MDS_AFC
}

######################################################################
######################################################################
#																	 #
#								MTween 								 #
#																	 #
######################################################################
######################################################################
# Tweening lib section!

###################################
# MTween function globals:

# Name of Workers for each operation:
global MTwn_Position_Function = "MTwn_Cent_Pivot_Position"
global MTwn_Resize_Function = "MTwn_Resize"
global MTwn_Rotate_Function = "MTwn_Rotate"

# The Last used ID, allows you to just say 'and now do this' rather than defining the ID again
global MTwn_LastID = ""

# Default to Center coords vs Top Left
global MTwn_UseCenterDefault = false

# Order of IDs to render
global MTwn_Order = ""


function MTwn_Init()
{

}

######################################################################
# MTween Functions

# Sets the raw data for an ID
function MTwn_SetRaw(string ID, clip c)
{
	eval("global MTwn_data_" + ID + "_raw = c.killaudio()")
}

###################################
# Go functions:
# For each ID in MTwn_Order, we render into a blank clip that we generate here, and return that from this function

# MTwn_Go_I: Instant update
function MTwn_Go_I(clip c, int frame, string "OrderOverride")
{
	# Load Order
	OrderOverride = default(OrderOverride,MTwn_Order)
	Assert(OrderOverride != "","MTwn_Go_# should not be called with an empty OrderOverride string!: ~" + OrderOverride + "~")

	# Trim the start of the clip, which must remain untouched (note we ditch this later if frame = 0)
	start = trim(c,0,frame - 1)

	# effect doesn't exist in Instant, but would be the animated transition effect

	# end is the remainder of the clip with the new ongoing layout applied
	end = trim(c,frame,0)
	end = BlankClip(end).audiodubex(end)
	end = intMTwn_Ongoing_Loop(end,frame,OrderOverride)

	# If frame is 0, ignore start
	out = frame == 0 ? end : start + end

	return out
}

# MTwn_Go_I: Animated update
function MTwn_Go_A(clip c, int frame, string "OrderOverride1", string "OrderOverride2")
{
	# Load Order
	OrderOverride1 = default(OrderOverride1,MTwn_Order)
	OrderOverride2 = default(OrderOverride2,MTwn_Order)
	Assert(OrderOverride1 != "","MTwn_Go_# should not be called with an empty OrderOverride1 string!: ~" + OrderOverride1 + "~")
	Assert(OrderOverride2 != "","MTwn_Go_# should not be called with an empty OrderOverride2 string!: ~" + OrderOverride2 + "~")

	# Trim the start of the clip, which must remain untouched (note we ditch this later if frame = 0)
	start = trim(c,0,frame - 1)

	# effect is the animated transition effect
	effect = trim(c,frame,frame + MTwn_AFC)
	effect = BlankClip(trim(c,frame,frame + MTwn_AFC)).audiodubex(effect)
	effect = intMTwn_Interpolate_Loop(effect,frame,OrderOverride1)

	# end is the remainder of the clip with the new ongoing layout applied
	f_end = frame + MTwn_AFC + 1
	end = trim(c,f_end,0)
	end = BlankClip(trim(c,f_end,0)).audiodubex(end)
	end = intMTwn_Ongoing_Loop(end,f_end,OrderOverride2)

	# If frame is 0, ignore start
	out = frame == 0 ? effect + end : start + effect + end

	return out
}

###################################
# intMTwn_Interpolate_Loop is a recursive function
# It iterates through each ID in the supplied Order string and renders them with intMTwn_Interpolate
function intMTwn_Interpolate_Loop(clip c, int frame, string Order)
{
	# Find the first index of a ,
	index = FindStr(Order,",")

	# Clip off the head as the current ID
	ThisID = index == 0 ? Order : midstr(Order,1,index - 1)
	# Retain the remainder of the string for the recursion
	Order = index == 0 ? "" : midstr(Order,index + 1)

	# Render with interpolation render function if this clip is marked as having changed
	# Otherwise just use Ongoing
	eval("bother = MTwn_Data_" + ThisID + "_active")
	MyReturn = bother == true ? intMTwn_Interpolate(c, ThisID, frame) : intMTwn_Ongoing(c, ThisID, frame)

	# If there is more to do, recurse
	MyReturn = Order == "" ? MyReturn : intMTwn_Interpolate_Loop(MyReturn, frame, Order)

	return MyReturn
}

###################################
# intMTwn_Ongoing_Loop is a recursive function
# It iterates through each ID in the supplied Order string and renders them with intMTwn_Ongoing
function intMTwn_Ongoing_Loop(clip c, int frame, string Order)
{
	index = FindStr(Order,",")

	# Clip off the head as the current ID
	ThisID = index == 0 ? Order : midstr(Order,1,index - 1)
	# Retain the remainder of the string for the recursion
	Order = index == 0 ? "" : midstr(Order,index + 1) # Automatically uses the rest of the string if end point is not defined

	# Shift Target data into Current Data as we are an instant change
	MTwn_Shift(ThisID)
	# Render with ongoing render function
	MyReturn = intMTwn_Ongoing(c, ThisID, frame)

	# If there is more to do, recurse
	MyReturn = Order == "" ? MyReturn : intMTwn_Ongoing_Loop(MyReturn, frame, Order)

	return MyReturn
}

###################################
# intMTwn_Interpolate is pretty much the main function of MTween. It handles taking the start data and sending it to each
# worker function (as defined as the MTwn variables) and otherwise make things happen
function intMTwn_Interpolate(clip c, string ID, int frame)
{
	# c is the clip we must render into.

	# Set up ID loading vars
	stx = "MTwn_Data_" + ID
	str = "global " + stx

	# Set raw to, appropriately, the raw footage
	eval("raw = " + stx + "_raw")
	# Get the part that applies for just this animated transition
	raw = trim(raw,frame,frame + MTwn_AFC)

	# Get the start positions for this ID
	# Current:
	eval("me_w = " + stx + "_w")
	eval("me_h = " + stx + "_h")
	eval("me_x = " + stx + "_x")
	eval("me_y = " + stx + "_y")
	eval("me_r = " + stx + "_r")
	# Target:
	eval("me_Tw = " + stx + "_Tw")
	eval("me_Th = " + stx + "_Th")
	eval("me_Tx = " + stx + "_Tx")
	eval("me_Ty = " + stx + "_Ty")
	eval("me_Tr = " + stx + "_Tr")


	# These are the param blocks for the majority of functions
	me_block = "me_w,me_h,me_x,me_y,me_r,"
	mT_block = "me_Tw,me_Th,me_Tx,me_Ty,me_Tr,"

	# Step 1: Resize:
	# When we resize, we will generate a clip of size of the larger of the current or target width
	# However, these two sizes may actually be the same, so we can check and see if we actually need to bother animating the resize at all:
	test1 = me_w == me_Tw ? 1 : 0
	test2 = me_h == me_Th ? 1 : 0
	# And if so, don't bother animating at all.
	draw = (test1 + test2) == 2 ? eval(MTwn_Resize_Function + "(raw, " + me_block + me_block + "MTwn_AFC)") : \
	eval("animate(raw,0,MTwn_AFC,MTwn_Resize_Function, " + me_block + mT_Block + "0," + me_block + mT_Block + "MTwn_AFC)")

	# Step 2: Rotation:
	# For the purposes of simplicity, we set me_w/h to be the size of the produced resized clip 'draw':
	me_w = draw.width()
	me_h = draw.height()

	# Once again, we perform a test to verify that we actually have to bother during an animated resize
	test1 = me_r == 0 ? 1 : 0
	test2 = me_Tr == 0 ? 1 : 0

	nan = (test1 + test2) == 2 ? 0 : eval("""
	# If the clip is rotated at all, we must ensure there is enough border space for it to be rotated into by adding borders, based on the diagonal dimention of the clip
	# This ensures there is sufficient space. Additionally, make the clip perfectly square, so turn left/right functions can be used.

	hyp = 2 + round(sqrt(me_w * me_w + me_h * me_h)) # With an extra 2 pixels just to be safe
	# Also: Ensure we don't get burned on any rounding errors
	hyp_w1 = (hyp - draw.width()) / 2
	hyp_w2 = hyp - draw.width() - hyp_w1
	hyp_h1 = (hyp - draw.height()) / 2
	hyp_h2 = hyp - draw.height() - hyp_h1

	draw = draw.addborders(hyp_w1,hyp_h1,hyp_w2,hyp_h2)

	# Now test if the rotation has changed or not, and if not, skip the animation
	test1 = me_r == me_Tr ? 1 : 0
	draw = test1 == 1 ? """ + MTwn_Rotate_Function + "(draw," + me_block + me_block + """MTwn_AFC) : \
	animate(draw,0,MTwn_AFC,MTwn_Rotate_Function, """ + me_block + mT_block +"0," + me_block + mT_block + """MTwn_AFC)
	""")

	# Step 3: Position:
	# Again, test if the positions have changed, if not, skip animating
	test1 = me_x == me_Tx ? 1 : 0
	test2 = me_y == me_Ty ? 1 : 0

	draw = (test1 + test2) == 2 ? eval(MTwn_Position_Function + "(c,draw, " + me_block + me_block + "MTwn_AFC)") : \
	eval("animate(c,0,MTwn_AFC, MTwn_Position_Function, draw, " + me_block + mT_block + "0, draw," + me_block + mT_block + "MTwn_AFC)")

	# Clip complete, return it
	return draw
}

###################################
# intMTwn_Ongoing provides the ongoing section of the clip, eg, it just arranges the clips without any animation ever
function intMTwn_Ongoing(clip c, string ID, int frame)
{
	# c is the clip we must render into.

	# Set up ID loading vars
	stx = "MTwn_Data_" + ID
	str = "global " + stx

	# Set raw to, appropriately, the raw footage
	eval("raw = " + stx + "_raw")
	# Get the part that applies for the rest of the video
	raw = trim(raw,frame,0)

	# Get the start positions for this ID
	# Current:
	eval("me_w = " + stx + "_w")
	eval("me_h = " + stx + "_h")
	eval("me_x = " + stx + "_x")
	eval("me_y = " + stx + "_y")
	eval("me_r = " + stx + "_r")

	# These are the param blocks for the majority of functions
	me_block = "me_w,me_h,me_x,me_y,me_r,"

	# Step 1: Resize:
	eval("draw = " + MTwn_Resize_Function + "(raw, " + me_block + me_block + "MTwn_AFC)")

	# Step 2: Rotation:

	nan = me_r != 0 ? eval("""
	# If the clip is rotated at all, we must ensure there is enough border space for it to be rotated into by adding borders, based on the diagonal dimention of the clip
	# This ensures there is sufficient space. Additionally, make the clip perfectly square, so turn left/right functions can be used.

	hyp = 2 + round(sqrt(me_w * me_w + me_h * me_h)) # With an extra 2 pixels just to be safe
	# Also: Ensure we don't get burned on any rounding errors
	hyp_w1 = (hyp - draw.width()) / 2
	hyp_w2 = hyp - draw.width() - hyp_w1
	hyp_h1 = (hyp - draw.height()) / 2
	hyp_h2 = hyp - draw.height() - hyp_h1

	draw = draw.addborders(hyp_w1,hyp_h1,hyp_w2,hyp_h2)

	draw = """ + MTwn_Rotate_Function + "(draw, " + me_block + me_block + """MTwn_AFC)
	""") : 0

	# Step 3: Position
	draw = eval(MTwn_Position_Function + "(c,draw, " + me_block + me_block + "MTwn_AFC)")

	# Clip complete, return it
	return draw
}

###################################
# An Ease function
function MTwn_SineInOut(float ratio)
{
	# Map ratio from 0 to 1 such that it resembles the curve of cos(0) to cos(PI), also mapped from 0 to 1. Basically half a sine wave
	angle = ratio * PI
	mycos = cos(angle)
	ratio = (1 - mycos) / 2
	return ratio
}

###################################
# MTwn_Position is the original position function that positions clips based on purely their own coordinates
function MTwn_Position(clip base, clip add, int w1, int h1, int x1, int y1, int r1,  int w2, int h2, int x2, int y2, int r2, int step, string "easeoverride")
{
	ratio = float(step) / MTwn_AFC

	###
	# Calculate Easing
	ease = MTwn_PS_EaseFunction != "" ? MTwn_PS_EaseFunction : MTwn_GB_EaseFunction
	ease = default(easeoverride,ease)

	eval(ease)
	###

	diff_x = round(float(x2-x1) * ratio)
	diff_y = round(float(y2-y1) * ratio)

	result_x = x1
	result_y = y1

	nan = MDS_ShowDebug == true ? eval ("""
	add=add.subtitle("x: " + string(result_x) + " y: " + string(result_y) + " " + string(step),add.width() / 2 - 30,add.height() / 2 - 15)
	""") : 0

	layer(base,add,"ADD",257,result_x + diff_x - round(add.width() / 2),result_y + diff_y - round(add.height() / 2))
}

###################################
# MTwn_Cent_Pivot_Position uses the rotation of a clip to pivot it around the center point of the clip
# This causes the output to appear as if the entier clip is rotating around the center point, rather than each clip rotating around its own center
function MTwn_Cent_Pivot_Position(clip base, clip add, int w1, int h1, int x1, int y1, int r1,  int w2, int h2, int x2, int y2, int r2, int step, string "easeoverride")
{
	ratio = float(step) / MTwn_AFC

	###
	# Calculate Easing
	ease = MTwn_PS_EaseFunction != "" ? MTwn_PS_EaseFunction : MTwn_GB_EaseFunction
	ease = default(easeoverride,ease)

	eval(ease)
	###

	pos_ratio = ratio

	# If we aren't doing rotation related math, that saves us a big headache
	nan = r1 == r2 ? eval("""
	result_x = x1 + round(float(x2-x1) * pos_ratio)
	result_y = y1 + round(float(y2-y1) * pos_ratio)
	"""): eval("""

	# But oh boy, if we are:
	# Firstly we must calculate the rotation ease:
	ratio = float(step) / MTwn_AFC

	###
	# Calculate Easing
	ease = MTwn_RT_EaseFunction != "" ? MTwn_RT_EaseFunction : MTwn_GB_EaseFunction
	ease = default(easeoverride,ease)

	eval(ease)
	###

	r = float(r1) + (float(r2-r1) * ratio)

	# Now, do all the maths:

	# Convert to Radians
	rrad = r * (pi / 180)
	r1rad = r1 * (pi / 180)
	r2rad = r2 * (pi / 180)

	# calculate displacement around the pivot point (center of the workspace)
	x1r0 = x1 - (base.width() / 2)
	y1r0 = y1 - (base.height() / 2)

	x2r0 = x2 - (base.width() / 2)
	y2r0 = y2 - (base.height() / 2)

	# Calculate the components that would be made up of the rotation at either end.
	x1r = sin(-r1rad) * y1r0 + cos(-r1rad) * x1r0
	y1r = sin(-r1rad) * x1r0 + cos(-r1rad) * y1r0

	x2r = sin(-r2rad) * y2r0 + cos(-r2rad) * x2r0
	y2r = sin(-r2rad) * x2r0 + cos(-r2rad) * y2r0

	# Interpolate position only on the unrotated displacement
	x = x1r + (float(x2r-x1r) * pos_ratio)
	y = y1r + (float(y2r-y1r) * pos_ratio)

	# Take the pivot point coords, and add on the displacemenet caused by rotation around the pivot
	result_x = (base.width() / 2) + round(sin(-rrad) * y + cos(-rrad) * x)
	result_y = (base.height() / 2) + round(sin(-rrad) * x + cos(-rrad) * y)
	""")

	# Show debug data:
	nan = MDS_ShowDebug == true ? eval ("""
	add=add.subtitle("x: " + string(result_x) + " y: " + string(result_y) + " " + string(step),add.width() / 2 - 30,add.height() / 2 - 15)
	""") : 0

	layer(base,add,"ADD",257,result_x - round(add.width() / 2),result_y - round(add.height() / 2))
}

###################################
# MTwn_Resize is the worker function that performs resizing of clips, appropriately enough
function MTwn_Resize(clip c, int w1, int h1, int x1, int y1, int r1,  int w2, int h2, int x2, int y2, int r2, int step, string "easeoverride")
{
	# Calculate the maximum width
	mw = w1 > w2 ? w1 : w2
	mh = h1 > h2 ? h1 : h2

	ratio = float(step) / MTwn_AFC

	###
	# Calculate Easing
	ease = MTwn_RS_EaseFunction != "" ? MTwn_RS_EaseFunction : MTwn_GB_EaseFunction
	ease = default(easeoverride,ease)

	eval(ease)
	###

	# Calculate the target width and height
	diff_w = round(float(w2-w1) * ratio)
	diff_h = round(float(h2-h1) * ratio)

	w = w1 + diff_w
	h = h1 + diff_h

	# Test if this is an exact multiple of the base resolution
	test1 = w % c.width()
	test2 = h % c.height()

	# Select which resize filter to use based on the result of this test.
	# In theory you might want to resize in a non aspect locked manner, but this functions assumes the ratio will always be locked
	rsz = (test1 + test2) == 0 ? eval(MDS_Resize_IntegerFactor + "(c,w,h)") : eval(MDS_Resize_NonIntFactor + "(c,w,h)")

	# Generate a blank clip to position our output in that has the width/height basde on the maximums
	out = BlankClip(c,width = mw,height = mh)

	# Calculate where this particular frame should be positioned in this space:
	x_pos = round((mw - (w1 + diff_w)) / 2)
	y_pos = round((mh - (h1 + diff_h)) / 2)

	# Show debug data:
	nan = MDS_ShowDebug == true ? eval ("""
	rsz=rsz.subtitle("w: " + string(w) + " h: " + string(h) + " " + string(step),rsz.width() / 2 - 30,rsz.height() / 2 - 60)
	""") : 0

	# Layer the resized footage into the blank clip and return it
	return layer(out,rsz,x = x_pos, y = y_pos)
}

###################################
# MTwn_Rotate employs the use of an external filter to rotate footage through non-right angles, but also employs the use of turnleft/right/180 to more efficiently
# manage rotations, especially for ongoing footage.
function MTwn_Rotate(clip c, int w1, int h1, int x1, int y1, int r1,  int w2, int h2, int x2, int y2, int r2, int step, string "easeoverride")
{
	ratio = float(step) / MTwn_AFC

	###
	# Calculate Easing
	ease = MTwn_RT_EaseFunction != "" ? MTwn_RT_EaseFunction : MTwn_GB_EaseFunction
	ease = default(easeoverride,ease)

	eval(ease)
	###

	# This simply interpolates between the two given values. This does not attempt to find the shortest rotational distance
	# We use a function in SetTargets to remape rotations into a common space, we may not always want this so this function remains ambilent to this
	# concept at this point
	r = float(r1) + (float(r2-r1) * ratio)

	# However, when deciding if we should use a 90 degree rotation matrix over a rotation plugin, we really ought to make that decision here.
	# So, 1) Multiply by 4 to round only 0.125 down to 0, as even small rotations are often visible/required, mainly due to ease functions
	rint = round(r * 4)
	# Map this to a detection range:
	rint = ((rint + 180 * 4) % (360 * 4)) - (180 * 4)

	skipit = false

	# Is it 0?
	nan = rint == 0 ? eval("""
	# Do nothing!
	skipit = true
	""") : 0

	# Is it 90?
	nan = rint == (90 * 4) ? eval("""
	b = BlankClip(c)
	c = c.TurnRight()

	c = layer(b,c,x = round((b.width() - c.width()) / 2),y = round((b.height() - c.height()) / 2))
	skipit = true
	""") : 0

	# Is it -180?
	nan = rint == -(180 * 4) ? eval("""
	c = c.Turn180()
	skipit = true
	""") : 0

	# Is it -90?
	nan = rint == -(90 * 4) ? eval("""
	b = BlankClip(c)
	c = c.TurnLeft()

	c = layer(b,c,x = round((b.width() - c.width()) / 2),y = round((b.height() - c.height()) / 2))
	skipit = true
	""") : 0

	# Attempt to rotate by a non right angle quantity:
	try
	{
		# But only if we haven't already caught this with turn left/right/180
		c = skipit == false ? eval(MTwn_RotationPluginCall) : c
	}
	catch (err_msg)
	{
		Assert(0 == 1, """Couldn't perform '""" + MTwn_RotationPluginCall + """'? You may need to get the Rotate plugin from the avisynth website, or use MDS_ChangeRotationWorker("your filter call here")
""" + err_msg)
	}

	# Display Debug info:
	nan = MDS_ShowDebug == true ? eval ("""
	c=c.subtitle("r: " + string(round(r)) + " " + string(step),c.width() / 2 - 30,c.height() / 2 - 0)
	""") : 0

	# Return clip
	return c
}

###################################
# MTwn_SetupID does the basic legwork of setting up variables
function MTwn_SetupID(string "ID", int "x", int "y", int "w", int "h", int "r", bool "is_center")
{
	# Obtain last used ID if not specified
	ID = default(ID,MTwn_LastID)
	is_center = default(is_center,MTwn_UseCenterDefault)

	stx = "MTwn_Data_" + ID
	str = "global " + stx

	w = default(w,100)
	h = default(h,100)
	x = default(x,0)
	y = default(y,0)
	r = default(r,0)

	eval(str + "_Ox = x")
	eval(str + "_Oy = y")
	eval(str + "_Ow = w")
	eval(str + "_Oh = h")
	eval(str + "_Or = r")

	# Use recall to set up the Target data from the O variables above, just saves wring the code here.
	MTwn_Recall(ID)

	eval(str + "_x = x")
	eval(str + "_y = y")
	eval(str + "_w = w")
	eval(str + "_h = h")
	eval(str + "_r = r")
}

###################################
# MTwn_SetTargets sets the targets of the given ID.
function MTwn_SetTargets(string "ID", int "x", int "y", int "w", int "h", int "r", bool "is_center")
{
	# Obtain last used ID if not specified
	ID = default(ID,MTwn_LastID)
	is_center = default(is_center,MTwn_UseCenterDefault)

	# Setup variable strings
	stx = "MTwn_Data_" + ID
	str = "global " + stx

	# Attempt to set the values, if we fail then chances are this ID does not exist
	try
	{
		# Stored data is always the center.
		x = default(x,-9999)
		y = default(y,-9999)
		eval("w = default(w," + stx + "_Tw)")
		eval("h = default(h," + stx + "_Th)")
		eval("r = default(r," + stx + "_Tr)")

		# If these are non -9999, replace the current target data for this ID with this information, and set it as active
		eval(str + "_active = true")

		# If there is a defined x or y, shift for the purpose of centering as needed (all coords are centered due to rotation)
		centerstring = is_center == true ? "x" : "x + round(w / 2)"
		nan = x == -9999 ? 0 : eval(str + "_Tx = " + centerstring)

		centerstring = is_center == true ? "y" : "y + round(h / 2)"
		nan = y == -9999 ? 0 : eval(str + "_Ty = " + centerstring)

		# Possibly correct the rotation:
		r = MTwn_RotationMap(r)

		# Update the remaining targets:
		eval(str + "_Tw = w")
		eval(str + "_Th = h")
		eval(str + "_Tr = r")
	}
	catch (err_msg)
	{
		# If this fails, this frame probably doesn't exist at all, and we probably don't care because we're just precautionarily setting them
	}

	MTwn_LastID = ID
}

###################################
# This prevents us from 'over rotating', and leaves the worker functions ambivilent about if they should be able to not use minimum rotational distances or not
function MTwn_RotationMap(int r)
{
	r = r >= 180 ? MTwn_RotationMap(r - 360) : r
	r = r < -180 ? MTwn_RotationMap(r + 360) : r
	return r
}


###################################
# MTwn_Shift shifts the current vars into the O vars, and then the T vars into the current vars
function MTwn_Shift(string "ID")
{
	# Obtain last used ID if not specified
	ID = default(ID,MTwn_LastID)

	stx = "MTwn_Data_" + ID
	str = "global " + stx

	# Store the old values in the O registers
	eval(str + "_Ox = " + stx + "_x")
	eval(str + "_Oy = " + stx + "_y")
	eval(str + "_Ow = " + stx + "_w")
	eval(str + "_Oh = " + stx + "_h")
	eval(str + "_Or = " + stx + "_r")

	# Change the current to the Targets
	eval(str + "_x = " + stx + "_Tx")
	eval(str + "_y = " + stx + "_Ty")
	eval(str + "_w = " + stx + "_Tw")
	eval(str + "_h = " + stx + "_Th")
	eval(str + "_r = " + stx + "_Tr")

	eval(str + "_active = false")
}

###################################
# MTwn_Auto_Recall recalls the O variables into the T vars for everything registered
function MTwn_AutoRecall()
{
	intMTwn_AutoRecall_loop(MTwn_Order)
}

###################################
# intMTwn_AutoRecall_loop is the recursive function which loops
function intMTwn_AutoRecall_loop(string Order)
{
	# Find the first index of a ,
	index = FindStr(Order,",")

	# Clip off the head as the current ID
	ThisID = index == 0 ? Order : midstr(Order,1,index - 1)
	# Retain the remainder of the string for the recursion
	Order = index == 0 ? "" : midstr(Order,index + 1)

	# Recall this ID
	MTwn_Recall(ThisID)

	# If there is more to do, recurse
	l = Order == "" ? 0 : intMTwn_AutoRecall_loop(Order)
}

###################################
# MTwn_Recall recalls the O variables into the T vars
function MTwn_Recall(string "ID")
{
	# Obtain last used ID if not specified
	ID = default(ID,MTwn_LastID)

	stx = "MTwn_Data_" + ID
	str = "global " + stx

	# Recall the O values into the Target values
	eval(str + "_Tx = " + stx + "_Ox")
	eval(str + "_Ty = " + stx + "_Oy")
	eval(str + "_Tw = " + stx + "_Ow")
	eval(str + "_Th = " + stx + "_Oh")
	eval(str + "_Tr = " + stx + "_Or")

	eval(str + "_active = true")
}

###################################
# Applies our audio clip onto the provided input, just in case we've messed anything up somehow
function MTwe_RestoreAudio(clip c)
{
	try
	{
		out = audiodubex(out,MTwn_Data_Audio_raw)
	}
	catch (err_msg) {}
}

###################################
###################################
