# TRACMIT: Algorithm for Single cells on Micropatterns through mITosis

## Introduction

TRACMIT is written as an ImageJ ActionBar containing ImageJ 1 Macro code. It allows for the tracking and characterization of the mitotic plate's division angle of cells undergoing mitosis on micropatterns.

### Repository Contents
- **Readme.md** - This file
- **TRACMIT User Guide.pdf** - Interface and user guide
- **LICENSE** - License file
- **TRACMIT_1.1.ijm** - The actual code of TRACMIT, in ActionBar form
- **TRACMIT_Settings_1.1.ijm** - A sub-ActionBar that contains methods for setting TRACMIT parameters, as well as a series of wizards to help set most parameters interactively.
- **updateFile.bat** - Windows Batch script useful for when updating this repository. Not of use to end users.
- **TRACMIT Default Settings.txt** - Text file with all de default settings for TRACMIT, can be loaded using the **Load Parameters** button.

## Installation

### Dependencies
After completing the step above make sure that the following update sites are enabled:
- **IBMP-CNRS** - Contains the ActionBar Plugin by Jerôme Mutterer
- **PTBIOP**  - Contains the BIOPLib and attached plugins used for managing TRACMIT's settings and other internals
- **Imagescience**  - Contains the FeatureJ Laplacian Plugin used by TRACMIT

The simplest way to install TRACMIT is to use the TRACMIT Update site through [Fiji](https://fiji.sc/):

1. From Fiji, go to **Help > Update...**
2. Select **Manage Update Sites**
3. Click on **Add Update Site**, this will create a new line on the table
4. Change the **Name** to "TRACMIT", for clarity's sake
5. In the **URL** column, enter or paste *http://biop.epfl.ch/TRACMIT/*
6. Click on **Close**
7. Finally click on **Apply Changes** and restart Fiji

After these steps, you should find **"TRACMIT_xx"** under **Plugins > ActionBar > TRACMIT**

## Use

To test it, you can download a sample dataset from ZENODO with the following DOI.
Please see the User Guide if you have questions

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.232218.svg)](https://doi.org/10.5281/zenodo.232218)

1. Download the file **TRACMIT Default Settings.txt** from this repository
2. Load the file above using the **Load Parameters** button.
2. Click on **Select Raw Image** and point it to the folder you just extracted.
3. Select one of the images
4. Click on **Measure Current Image**


## License

This software is offered under the "[Revised BSD License](https://en.wikipedia.org/wiki/BSD_licenses#3-clause_license_.28.22Revised_BSD_License.22.2C_.22New_BSD_License.22.2C_or_.22Modified_BSD_License.22.29)" which is described in the LICENCE file contained within this repository.
