# ASMIT: Algorithm for Single cells on Micropatterns through mITosis

## Introduction

ASMIT is written as an ImageJ ActionBar containing ImageJ 1 Macro code. It allows for the tracking and characterization of the mitotic plate's division angle of cells undergoing mitosis on micropatterns.

### Repository Contents
- **Readme.md** - This file
- **LICENSE** - License file
- **ASMIT_1.0.ijm** - The actual code of ASMIT, in ActionBar form
- **updateFile.bat** - Windows Batch script useful for when updating this repository. Not of use to end users.
- **ASMIT Default Settings.txt** - Text file with all de default settings for ASMIT, can be loaded using the **Load Parameters** button.

## Installation

The simplest way to install ASMIT is to use the ASMIT update site through [Fiji](https://fiji.sc/):

1. From Fiji, go to **Help > Update...**
2. Select **Manage Update Sites**
3. Click on **Add Update Site**, this will create a new line on the table
4. Change the **Name** to "ASMIT", for clarity's sake
5. In the **URL** column, enter or paste *http://biop.epfl.ch/ASMIT/*
6. Click on **Close**
7. Finally click on **Apply Changes** and restart Fiji

After these steps, you should find **ASMIT** under **Plugins > ActionBar**

### Dependencies
After completing the step above make sure that the following update sites are enabled:
- **IBMP-CNRS** - Contains the ActionBar Plugin by Jerôme Mutterer
- **PTBIOP**  - Contains the BIOPLib and attached plugins used for managing ASMIT's settings and other internals
- **Imagescience**  - Contains the FeatureJ Laplacian Plugin used by ASMIT
## Use

To test it, you can download a sample dataset from ZENODO with the following DOI

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.232218.svg)](https://doi.org/10.5281/zenodo.232218)

1. Unzip the file, then load the settings file **ASMIT Default Settings.txt** using the **Load Parameters** button.
2. Click on **Select Raw Image** and point it to the folder you just extracted.
3. Select one of the images
4. Click on **Measure Current Image**


## License

This software is offered under the "[Revised BSD License](https://en.wikipedia.org/wiki/BSD_licenses#3-clause_license_.28.22Revised_BSD_License.22.2C_.22New_BSD_License.22.2C_or_.22Modified_BSD_License.22.29)" which is described in the LICENCE file contained within this repository.
