import("MDS.avsi")

top = ImageSource("MDS_TC_Red.png",0,1000,fps=30,pixel_type="RGB32").AudioDub(blankclip())
bot = ImageSource("MDS_TC_Blue.png",0,1000,fps=30,pixel_type="RGB32").AudioDub(blankclip())

top = top.subtitle("What is MDS.avsi?\nWhat does it do?",256,(384/2),0,299,"Nathan",64,$FFFFFF,000000,5,30,2)

bot = bot.subtitle("Well, that certainly\nis a question!",256,384 / 3,0,399,"Nathan",64,$FFFFFF,000000,5,30,2)
bot = bot.subtitle("And this animation is\nhere to help show you!",256,2 * (384 / 3),0,399,"Nathan",24,$FFFFFF,000000,5,30,2)

top = top.subtitle("It's a script to help\nprovide cool\ntransition effects\nfor NDS content",256,(384/3),300,499,"Nathan",64,$FFFFFF,000000,5,30,2)

bot = bot.subtitle("It aims to be useful\nfor eg NDS and 3DS\nLet's Play videos",256,2 *384 / 5,400,599,"Nathan",64,$FFFFFF,000000,5,30,2)

top = top.subtitle("But anything goes!\nSometimes you just\nneed to see\none screen",256,(384/3),500,799,"Nathan",64,$FFFFFF,000000,5,30,2)

bot = bot.subtitle("Sometimes you'll\nneed both...",256,2.3 *384 / 5,600,799,"Nathan",64,$FFFFFF,000000,5,30,2)

top = top.subtitle("Also",256,1.7*384/3,800,999,"Nathan",64,$FFFFFF,000000,5,30,2)
bot = bot.subtitle("Rotations!",256,1.7*384 / 3,800,999,"Nathan",64,$FFFFFF,000000,5,30,2)

Ex = ImageSource("MDS_TC_Green.png",0,1000,fps=30,pixel_type="RGB32").Subtitle("And more???",256,1.7*384/3,0,1000,"Nathan",64,$FFFFFF,000000,5,30,2)

MDS_SetAFC(30)
MDS_QualitySettings()
MDS_SetupDS(top,top_override = top,bot_override = bot)

MTwn_SetRaw("Ex",Ex)
MTwn_SetupID("Ex")
global MTwn_Order = "T,B,Ex"
MTwn_SetTargets("Ex", MDS_Wrk_w +MDS_A_w,Mds_Wrk_h / 2 , MDS_A_2w,MDS_A_2h, 0,true)

MDS_Custom_TargetData(MDS_A_2w,MDS_A_2h,MDS_A_2w,MDS_A_2h,  MDS_Wrk_w / 2, -MDS_A_h , MDS_Wrk_w / 2, MDS_Wrk_h +MDS_A_h, 0,0, true,true)
MDS_Custom()

MDS_VStackA(100)
MDS_BotVA(200)
MDS_TopVA(300)
MDS_TopH(350)
MDS_BotHA(400)
MDS_BotV(450)
MDS_QuickTopA(500)
MDS_TopH(550)
MDS_SBSA(600)
MDS_Custom_TargetData(MDS_A_2w,MDS_A_2h,MDS_A_2w,MDS_A_2h, MDS_Border - MDS_A_2w,(MDS_Wrk_h - MDS_A_2h) / 2,    MDS_Wrk_w - MDS_Border,(MDS_Wrk_h - MDS_A_2h) / 2,	0,0)
MDS_CustomA(700)
MDS_Custom_TargetData(MDS_A_2w,MDS_A_2h,MDS_A_2w,MDS_A_2h, MDS_Border - MDS_A_2w,(MDS_Wrk_h - MDS_A_2h) / 2,    MDS_Wrk_w - MDS_Border,(MDS_Wrk_h - MDS_A_2h) / 2,	-90,-90)
MDS_Custom(750)
MDS_Book_VStackScaleA(800)
MDS_VStackA(850)

MDS_Custom_TargetData(MDS_A_2w,MDS_A_2h,MDS_A_2w,MDS_A_2h,  MDS_Wrk_w / 2, -MDS_A_h , MDS_Wrk_w / 2, MDS_Wrk_h +MDS_A_h, 0,0, true,true)
MDS_CustomA(900)

MTwn_SetTargets("Ex", -MDS_A_w,Mds_Wrk_h / 2, MDS_A_2w,MDS_A_2h, 0,true)
MDS_CustomA(930)

trim(100,1000)

crop(MDS_Border,0,-MDS_Border,0)
LanczosResize(width() / 2, height() / 2)
#ChangeFPS(15)