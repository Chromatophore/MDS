# MDS
Avisynth library to assist with tweening Nintendo DS & 3DS footage between a selection of layouts. [gifv link of VV](http://i.imgur.com/a8s7OwI.gifv)

![Animation showing what MDS does](TitleCard/Titlecard.gif)

(Thanks Farrin N. Abbott, CopyCatFilms, [title card](http://www.copycatfilms.com/bloggin/silent-movie-title-card-free-download/) & Peter Wiegel, [font](http://www.1001fonts.com/nathan-font.html))

## What is it?

MDS is an avisynth library script designed to easily facilitate the use of animated transition effects from one layout of a selection of clips to another (generating in between frames, otherwise known as 'tweening'). Generally, you are required to include an origin points when animating clips in this fashion, which can quickly make editing difficult and slow. However, MDS is able to store and recall this information for you when you edit in a chronological order, allowing you to quickly produce clean, easy to read scripts with a large number of effects, which remain easy to revise and transfer to other similar projects. Really, MDS is a DS/3DS specific frontend to MTwn, a more somewhat versatile tweening engine that does most of the hard work.

## Latest version

The current version of MDS is r5. Many of the layout function names have been revised, so older scripts will need to be updated (or a translation script written).

## Installation

In order to use this library, you will need a functioning installation of avisynth. The only file you *need* from this project is **MDS.avsi**. You can place it your avisynth plugins directory, or use the import() command to import this script only when you need it. In order to use Rotation effects, you will require a rotation plugin for avisynth. Any plugin can be used, however I would suggest the rotate plugin from http://avisynth.org.ru/rotate/rotate.html

## Licensing

Please see the file called LICENSE.

## Usage

MDS produces footage with the expectation of uploading to youtube. As such, it produces footage that is in excess of 720p. In DS mode, this will be 1280x768. In 3DS mode, this will be 1600x960. In both cases, these correspond to useful integer magnifications of the screens, allowing you to use point resizes for the majority of scenes, allowing for only one blended resize (on youtube)

DS footage is expected to be in the format of 256x384, vertically stacked. 3DS footage is expected to be in the format of 400x480, vertically stacked with the lower screen centralised.

To get started, ensure that MDS.avsi is imported if required (ie, when it is not in your plugins dir). Then, load your footage as you normally would, edit out unwanted sections etc. When this process is complete, begin calling MDS initialisation functions that are appropriate for your content. For example:

```
import("MDS.avsi")

# Load Footage
Avisource("My_DS_Recording.avi")
ChangeFPS(60)

# Edit it as required
Trim(1234,5678)

# Use some higher quality transition effects. If this is too intensive to preview, we can use MDS_DraftSettings()
MDS_QualitySettings()
# Initialize our project as a DS (as opposed to 3DS) project:
MDS_SetupDS()
```

This should get you started with a vertically stacked layout. From here, provided you follow a couple of rules, you shouldn't have too many problems:  
1. Always work in chronological order, lowest frame numbers first.  
2. Do your editing before you start (or after you stop) using MDS transition effects, or your output will become desynchronised.

From where your script is now, you can call layout functions, an exhaustive list w/images is available for [DS](Layouts/list.md) and [3DS](Layouts3DS/list.md).

The main thing to know is that there are 2 versions of every layout: MDS_#### and MDS_####A. Functions without an A will apply their new layout instantly. Functions with an A will animate the transition to the new layout (you'll mostly want these probably). Here is a selection of what are probably the most worthwhile layouts. All the built in layouts can be seen in DS_Test.webm, and found in the test AVS files.
```
MDS_TopHA(100)
MDS_BotHA(200)
MDS_TopVA(300)
MDS_BotVA(400)
MDS_VStackA(500)
MDS_VStackGapA(600)

MDS_DissolveToTop(700)
MDS_DissolveToBot(800)
MDS_FadeToTop(900)
MDS_FadeToBot(1000)

MDS_VStackA(1100)
MDS_BookA(1200)
MDS_BookGapA(1300)
```

## Other usage notes

If your content would benefit from being 16:9 widescreen, you can set wide = true when calling SetupDS/Setup3DS. If your content is largely being used with eg BookGap, I would suggest doing this.

You can create custom layouts with MDS_Custom_TargetData and MDS_Custom/MDS_CustomA. Usage notes to follow.

You can modify a *large* number of aspects of both MDS and MTwn, the tweening engine built behind MDS.
