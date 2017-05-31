
/* TRACMIT: an effective pipeline for tracking and analyzing cells on micropatterns
 *  through mitosis
 *  Olivier Burri, Benita Wolf, October 14 2014
 *  EPFL - SV - PTECH - PTBIOP
 *  http://biop.epfl.ch
 *   -------------------------
 *  For Benita Wolf, UPGON
 *  Last update: January 6th 2017
 *  
 * Copyright (c) 2017, Benita Wolf, Olivier Burri
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the <organization> nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 * Updates:
 * 28.04.2017:  Fixed a bug that did not allow for the pipeline to be run without 
 * 				a call to "Settings"
 * 
 * 30.05.2017:  Implemented the following functionalities as per Reviewer comments
 * 				Increased the amount of comments in the code
 * 				Added parameter wizards to help estimate initial settings
 * 				Separated settings from TRACMIT pipeline to a new ActionBar
 * 				Corrected a bug where a default threshold was not properly set
*/

// Install common functions
call("BIOP_LibInstaller.installLibrary", "BIOP"+File.separator+"BIOPLib.ijm");

// Basic ActionBar Setup
var barPath = "/plugins/ActionBar/TRACMIT/";

var barName = "TRACMIT_Settings_1.1.ijm";

if(isOpen(barName)) {
	run("Close AB", barName);
}

run("Action Bar",barPath+barName);

exit();

//Start of ActionBar

<codeLibrary>

// Function helps you set the name of the Parameters Window


// helper functions

/*
 * To avoid reading each and every file (tens of thousands) in a high throughput experiment, we
 * use knowledge of the expected strucutre of the file name to find out which series are available
 * Structure of a file is:
 * ROW - COL(fld FIELD - time TIME - TIMESTAMP ms).tif"
 * Where 
 * 	ROW is the row number (A-H)
 * 	COL is the column number (1-12)
 * 	FIELD is in this case either 1 or 2, which is the nth image per well
 * 	TIME is an integer (1-t) marking the current timepoint number
 * 	TIMESTAMP is the number of milliseconds since the start of the experiment.
 * 	
 * 	This function is made to check if there are two fields from a 96 well plate image
 * 	by checking the existence of the first timepoint. 
 * 	It can be adapted to other plate types or filenaming conventions, however this is left to the user
 * 	
 * 	Otherwise, there is a simpler function, TODO
 */

function patternSettings() {
	names = newArray("Pattern Detecion Settings", 
					 "Pseudo Flatfield Blur",
					 "Pattern Mask Median Filter",
					 "Pattern Min Area", 
					 "Pattern Max Area",
					 "Pattern Detection Box Width",
					 "Pattern Detection Box Height",
					 "Pattern Min SD",
					 "Pattern Max SD",
					 "Perform SIFT Registration"
					 );
	types = newArray("m",
					 "n",
					 "n",
					 "n",
					 "s",
					 "n",
					 "n",
					 "n",
					 "n",
					 "b"
					 );
	defaults = newArray("",
						30,
						6,
						350,
						"Infinity",
						80,
						80,
						0.1,
						0.45,
						false
					);

	promptParameters(names, types, defaults);
}

function divisionDetectionSettings() {
	names = newArray("Division Detection Parameters", 
					 "Perform SIFT Registration",
					 "Laplacian Smoothing",
					 "Laplacian Threshold",
					 "Closing Iterations", 
					 "Closing Count",
					 "DNA Min Area",
					 "DNA Max Area",
					 "Division Area Tolerance",
					 "Division Angle Tolerance",
					 "Division Max distance",
					 "Division Detection Box Width",
					 "Division Detection Box Height",
					 "Division Detection Box X offset",
					 "Division Detection Box Y offset"
					 );
					 
	types = newArray("m",
					 "c",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n"
					 );
	defaults = newArray("",
					    false,
						2.5,
						-40,
						2,
						2,
						10,
						40,
						5,
						15,
						15,
						40,
						40,
						5,
						38
					);

	promptParameters(names, types, defaults);
}


function mitoticPlateSettings() {
	names = newArray("First Mitotic Plate Detection Parameters",
					 "Max Frames Until First Mitotic Plate", 
					 "Mitotic Plate Minimal Laplacian", 
					 "Max Total Area of single cell",
					 "ROI Threshold",
					 "Min Single Cell Area",
					 "Mitotic Plate Detection and Tracking",
					 "Mitotic Plate Min Area",
					 "Mitotic Plate Max Area",
					 "Mitotic Plate Min Major Axis",
					 "Mitotic Plate Max Major Axis",
					 "Mitotic Plate Min Minor Axis",
					 "Mitotic Plate Max Minor Axis",
					 "Mitotic Plate Min Axis Ratio",
					 "Mitotic Plate Max Axis Ratio",
					 "Mitotic Plate Max Movement",
					 "Mitotic Plate Max Frames to seek"
					 );
					 
	types = newArray("m",
					 "n",
					 "n",
					 "n",
					 "thr",
					 "n",
					 "m",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n",
					 "n"
					 );
	defaults = newArray("",
						2,
						-60,
						190,
						"Intermodes",
						20,
						"",
						30,
						80,
						11,
						17.1,
						2,
						6.8,
						2.9,
						6,
						5,
						3
					);

	promptParameters(names, types, defaults);
}

function toggleDebug() {
	isDebug = getBoolD("Debug Mode", false);
	
	setBool("Debug Mode", !isDebug);
}


function preProcessing() {
	ori = getTitle();
	sanitizeImage();
	run("Set Measurements...", "area centroid center fit shape area_fraction stack limit display redirect=None decimal=3");
	getVoxelSize(vx,vy,vz,u);
	nS = nSlices;
	close("Detection Mask");
	doSIFT = getBoolD("Perform SIFT Registration", true);
	imgBlur    = getDataD("Pseudo Flatfield Blur",30);

	// start with SIFT alignment if needed
	if (!matches(ori, ".* Corrected.*")) {
		run("Z Project...", "start=20 projection=[Min Intensity]");
		ff = getTitle();
		run("32-bit");
		
		run("Gaussian Blur...", "sigma="+imgBlur);
		getStatistics(area, mean, min, max);
		run("Divide...", "value="+max);
		imageCalculator("Divide", ori,ff);
		ori = ori+" Corrected";
		rename(ori);
	}
	
	if (doSIFT && !matches(ori, ".* Registered.*")) {
		resetMinAndMax();
		run("Enhance Contrast", "saturated=20.0");
		run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=512 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.96 maximal_alignment_error=10 inlier_ratio=0.05 expected_transformation=Rigid");
		siftID = getImageID();
		selectImage(ori);
		close();
		selectImage(siftID);
		ori = ori+" Registered";
		rename(ori);
		sanitizeImage();
		setVoxelSize(vx,vy,vz,u);
	}
	
	// Create an image to contain the detections
	getDimensions(xI,yI,zI,cI,tI);
	newImage("Detection Mask", "8-bit black", xI, yI, 1);
	selectImage(ori);

	lapSmooth  = getDataD("Laplacian Smoothing", 2.5);
	lapThr     = getDataD("Laplacian Threshold",-40);
	closeIter  = getDataD("Closing Iterations", 2);
	closeCount = getDataD("Closing Count", 2);
	
	run("Select None");
	// Make sure that the right images are open, or run them
	
	// 1. Laplacian
	if (!isOpen(ori+ " Laplacian") ) {
		run("FeatureJ Laplacian", "compute smoothing="+lapSmooth);
		setVoxelSize(vx,vy,vz,u);
	}

	//Select Laplacian Image
	selectImage(ori+ " Laplacian");
	lap = getImageID();

	// 2. Mask from Laplacian
		if (!isOpen(ori+ " Mask"))  {
		run("Duplicate...","title=["+ori+" Mask] duplicate");
		setThreshold(-10000, lapThr);
		run("Convert to Mask", "stack");
		run("Options...", "iterations="+closeIter+" count="+closeCount+" edm=Overwrite do=Close");
		
		setAutoThreshold("Default");
		setVoxelSize(vx,vy,vz,u);
	}
	selectImage(ori+ " Mask");
	mask = getImageID();

	// Make the images look good
	// Put main image on top
	selectImage(ori);
	
sH = 3*screenHeight/4;
	sW = 3*screenWidth/4;
	
	setLocation(0, 0, sH/2, sH/2);
	selectImage(lap);
	
	setLocation(sH/2 + 10, 0, sH/2, sH/2);

	selectImage(mask);
	
	setLocation(0, sH/2 + 10, sH/2, sH/2);
	
	selectImage("Detection Mask");
	
	setLocation(sH/2 + 10, sH/2 + 10, sH/2, sH/2);

	selectImage(ori);
}

function findDivisions() {
	ori = getTitle();
	nR = roiManager("Count");
	isRedo = true;
	if (nR > 3) {
		isRedo = getBoolean("Re-run Division Detection?");
		
		if (isRedo) {deleteRois(3,nR-1); };
	}

	lap = ori+" Laplacian";
	mask = ori+" Mask";
	
	dnaMinSize = getDataD("DNA Min Area", 10);
	dnaMaxSize = getDataD("DNA Max Area", 40);
	
	arDelta    = getDataD("Division Area Tolerance", 5);
	anDelta    = getDataD("Division Angle Tolerance",15);
	dDelta     = getDataD("Division Max distance", 15);
	
	if (isRedo) {
		selectImage(lap);
		getVoxelSize(vx,vy,vz,u);
		nS = nSlices;
		print("Slices: "+nS);
		k=0;
		for (f=1;f<nS;f++) {
			selectImage(mask);
			setSlice(f);
			// Detect Small nearby DNA.
			run("Analyze Particles...", "size="+dnaMinSize+"-"+dnaMaxSize+" show=Nothing display exclude clear slice");
			
			for (i=0; i<nResults; i++) {
				for (j=(i+1); j<nResults; j++) {
					ar1 = getResult("Area", i);
					ar2 = getResult("Area", j);
					an1 = getResult("Angle", i);
					an2 = getResult("Angle", j);
					x1 = getResult("XM", i);
					x2 = getResult("XM", j);
					y1 = getResult("YM", i);
					y2 = getResult("YM", j);
		
					d = sqrt(pow(x1-x2,2)+pow(y1-y2,2));
							
					if (abs(ar1-ar2) < arDelta && abs(getAngleDelta(an1,an2)) < anDelta && d < dDelta ) {
						selectImage(lap);
						x = newArray(2);
						x[0] = (x1/vx);
						x[1] = (x2/vx);
						y = newArray(2);
						y[0] = (y1/vy);
						y[1] = (y2/vy);

						// Check we are inside the mask.
						roiManager("Select", 2); // Select mask
						if (Roi.contains((x[0]+x[1])/2, (y[0]+y[1])/2)) {
							
							// TODO We could check here that we only keep the division closest to the beggining, and avoid duplicates already?
							k++;
							setSlice(f);
							makeSelection("points", x,y);
							Roi.setName("Potential Division #"+k);
							roiManager("Add");
							print("Found Division #"+k);
							
						} else {
							print("Not in mask");
						}
					}
				}
			}
		}
	}
	selectImage(ori);
}


function confirmDivisions() {
	ori = getTitle();
	lap = ori+" Laplacian";
	mask = ori+" Mask";
	nR = roiManager("Count");
	
	if (nR <= 3) {
		print("Image "+ori+": No Candidates for division confirmation");
		return;
	}

	candidateIdx = findRoiWithName("Selected Candidates");
	roiManager("Select", candidateIdx);
	getSelectionCoordinates(xp,yp);
	
	
	maxreturn = getDataD("Max Frames Until First Mitotic Plate", 2);
	
	minLapThr = getDataD("Mitotic Plate Minimal Laplacian", -60);
	maxAr     = getDataD("Max Total Area of single cell",180);
	nThr     = getDataD("ROI Threshold","Intermodes");
	minA     = getDataD("Min Single Cell Area",100);

		//Set the bounding box
	div_box_w = getDataD("Division Detection Box Width",40);
	div_box_h = getDataD("Division Detection Box Height",40 );
	div_box_x = getDataD("Division Detection Box X offset",5 );
	div_box_y = getDataD("Division Detection Box Y offset",38 );
	//SetData for pattern
	
	pattern_box_w = getDataD("Pattern Detection Box Width", 80 );
	pattern_box_h = getDataD("Pattern Detection Box Height", 80);
	
	isRedo = true;
	idx = findRoiWithName("Division Event.*");
	if (idx > 0) {
		isRedo = getBoolean("Re-run Detection Confirmation?");
		
		if (isRedo) {deleteRois(idx,nR-1); };
	}
	if (isRedo) {
		
		nR = roiManager("Count");
		getVoxelSize(vx,vy,vz,u);
		k=0;
		selectImage(ori);
		Overlay.clear;

		
		  oneCellArea = newArray(0);
		otherCellArea = newArray(0);
		
		for (i=3;i<nR;i++) {
			selectImage(lap);
			roiManager("Select", i);
			getSelectionCoordinates(xc,yc);
			Stack.getPosition(channel, slice, frame) ;
			x1 = xc[0];
			y1 = yc[0];
			x2 = xc[1];
			y2 = yc[1];
	
			x = (x1 + x2) / 2;
			y = (y1 + y2) / 2;

			selectImage(mask);
			// Check it's where we would expect it
			roiManager("Select", 2); // Select mask
			if (!Roi.contains(x, y)) {
				print("Not in Mask");
			} else {
				// Check if we already found it
				//Find neighbors
				idx = getNearestPattern(x,y, xp, yp);
				selectImage(ori);
				nNeigh = getNeighbors(nThr, minA);
				if (!(nNeigh <= 2) ) {
					print("Bad neighbors ("+nNeigh+")");
				} else {
					setSlice(frame) ;
					makeRectangle(xp[idx], yp[idx]-pattern_box_h,pattern_box_w,pattern_box_h);
					totAr = getTotalArea(nThr);
					isOneCell = getBoolean("Does this thresholded area contain exactly one cell, dividing or not?");

					if(isOneCell) {
						oneCellArea = Array.concat(oneCellArea,totAr); 
					} else {
						otherCellArea = Array.concat(otherCellArea,totAr); 
					}
				}
			}
			selectImage(ori);
			setSlice(frame);
			
			
		}

		Array.getStatistics(oneCellArea, one_min, one_max, one_mean, one_stdDev);
		Array.getStatistics(otherCellArea, other_min, other_max, other_mean, other_stdDev);

		exclArea = (1+0.2)*one_max;
		print("Excluding patterns with total area larger than  "+exclArea+" using "+nThr+" threshold");
		setData("Max Total Area of single Cell", exclArea);
		
	} // End redo

	// Make image viewable
	selectImage(ori);
	resetThreshold();
}

function findMitoticPlates() {

	ori = getTitle();
	
	idx = findRoiWithName("Division Event.*");

	if (idx < = 3) {
		print("No division events detected!");
		return;
	}

	run("Remove Overlay");
	
	
	mask = ori+" Mask";
	
	areaMin    = getDataD("Mitotic Plate Min Area",30);
	areaMax    = getDataD("Mitotic Plate Max Area",80);
	majorMin   = getDataD("Mitotic Plate Min Major Axis",11); 
	majorMax   = getDataD("Mitotic Plate Max Major Axis",17.1);
	minorMin   = getDataD("Mitotic Plate Min Minor Axis",2);
	minorMax   = getDataD("Mitotic Plate Max Minor Axis",6.8);
	arMin      = getDataD("Mitotic Plate Min Axis Ratio",3);
	arMax      = getDataD("Mitotic Plate Max Axis Ratio",6);
	dMax       = getDataD("Mitotic Plate Max Distance",5);
	maxFrames  = getDataD("Mitotic Plate Max Frames to seek", 3);
	
	nR = roiManager("Count");
	getVoxelSize(vx,vy,vz,u);
	// find all mitotic plates
	for(i=idx; i<nR;i++) {
		print("Hey");
		// For each position, look for the mitotic plates in time
		selectImage(mask);
		
		roiManager("Select", i);
		rName = Roi.getName;
		divID = substring(rName,indexOf(rName,"#")+1,lengthOf(rName));
		getSelectionBounds(xStart, yStart, w, h);
		run("Enlarge...", "enlarge=15");
		
		fr = getSliceNumber();
		lostF = 0;
		//um
		lastX = xStart*vx;
		lastY = yStart*vy;
		
		angle = newArray(0);
		slice = newArray(0);
		posX  = newArray(0);
		posY  = newArray(0);
		maj   = newArray(0);
		min   = newArray(0);
		are   = newArray(0);
	
		nFound = 0;
		lostF = 0;
		// Analyse going backwards
		while(lostF < maxFrames && fr > 0) {
			
			
			roiManager("Select", i);
			setSlice(fr);
			run("Enlarge...", "enlarge=15");
			run("Analyze Particles...", "size="+areaMin+"-"+areaMax+" display clear slice");
			found = false;
			for(r=0;r<nResults;r++) {
				ar = getResult("Area", r);
				in = getResult("Mean", r);
				ma = getResult("Major", r);
				mi = getResult("Minor", r);
				an = getResult("Angle", r);
				s  = getResult("Slice", r);
				px  = getResult("XM", r);
				py  = getResult("YM", r);
				aratio = getResult("AR", r);
				d = distance(lastX,lastY, px, py);
				if (d < dMax) {
					
					print("Distance OK: "+d);
					print("Major: "+ma+" vs. ["+majorMin+","+majorMax+"]");
					print("Minor: "+mi+" vs. ["+minorMin+","+minorMax+"]");
					print("Ratio: "+aratio+" vs. ["+arMin+","+arMax+"]");
					
					
					if (inRange(ma, majorMin, majorMax) && inRange(mi,  minorMin, minorMax) && inRange(aratio, arMin,arMax)) {
						// Found plate, keep angle data.
						r=nResults; // exit for loop
						angle = Array.concat(angle, an);
						slice = Array.concat(slice, s);
						posX = Array.concat(posX, px);
						posY = Array.concat(posY, py);
						maj = Array.concat(maj, ma);
						min = Array.concat(min, mi);
						are = Array.concat(are, ar);
						nFound++;
						found = true;
						lastX = px;
						lastY = py;
					}
				}
			}
			
			if (!found) { lostF++; } else { lostF = 0; }
			
			
			// Go to the next frame
			fr--;
		}

		print("Mitotic Plates found, (IDX="+divID+"): "+nFound);
		if(angle.length > 0) {
			// Save Results
			run("Clear Results");
			prepareTable("Angle Measurements");
			closeTable("Angle Measurements");
			prepareTable("Angle Measurements");
			updateResults();
			n = nResults;
			//Rows
			if(isHTImage(ori)) {
				well = substring(ori, lastIndexOf(ori, "Well ")+5, indexOf(ori, "-"));
				r = substring(well, 0,1);
				c = parseInt(substring(well, 1,lengthOf(well)));
				f = parseInt(substring(ori, lastIndexOf(ori,"Field ")+6,lengthOf(ori)));
			}
			label = File.directory;
			
			for (b=n; b<n+angle.length; b++) {

				// Draw a rectangle and add it to the overlay?
				
				//print(i);
				setResult("Label", b, label);
				setResult("Division ID", b, divID);
				
if(isHTImage(ori)) {
					setResult("Row", b, parseRowName(r));
					setResult("Col", b, c);
					setResult("Field", b, f);
				}
				
				setResult("Area", b, are[b-n]);
				setResult("Major", b ,maj[b-n]);
				setResult("Minor", b, min[b-n]);
				setResult("Angle", b, angle[b-n]);
				setResult("Slice", b, slice[b-n]);
				setResult("XM", b, posX[b-n]);
				setResult("YM", b, posY[b-n]);
				setResult("Area", b, are[b-n]);
			}
			updateResults();
			closeTable("Angle Measurements");
			selectWindow("Angle Measurements");
			updateResults();

			
			run("Clear Results");
			prepareTable("Angles Summary");
			closeTable("Angles Summary");
			prepareTable("Angles Summary");
			updateResults();
			n = nResults;
			print(n);
			
			Array.getStatistics(angle, amin, amax, amean, asdev);
			rName = parseRowName(r);
			setResult("Label", n, label);
			setResult("Division ID", n, divID);
			if(isHTImage(ori)) {
				setResult("Row", n, rName);
				setResult("Col", n, c);
				setResult("Field", n, f);
			}
			setResult("Last Angle", n, angle[0]);
			setResult("Angle StdDev", n, asdev);
			setResult("Angle Mean", n, amean);
			setResult("Number of Frames", n, nFound);
			updateResults();
			
			closeTable("Angles Summary");
			selectWindow("Angles Summary");

		}
	}
	selectImage(ori);
	
}

function segmentPatterns(start, medianR) {
	ori=getTitle();
	
	run("Select None");
	run("Z Project...", "start="+start+" projection=[Min Intensity]");
	run("32-bit");
	run("Smooth");
	minI = getTitle();
		
	getStatistics(area, mean, min, max);
	setThreshold(15, max);
	run("NaN Background");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	rename(ori+" Traps Mask");
	run("Median...", "radius="+medianR);
	
}

function getStartSlice() {
	getDimensions(x,y,c,z,t);
	start = 20;
	if(start >= (t-10) ) start = 0;

	return start;
}

function detectPatterns() {
	
	preProcessing();
	ori = getTitle();

	startSlice = getStartSlice();
	
	idx = findRoiWithName("Detected Traps");
	isRedo = true;
	
	if (idx != -1) {
		isRedo = getBoolean("Traps were detected. Re-run detection?");
	}

	close(ori+" Traps Mask");
	
	    medianR = getDataD("Pattern Mask Median Filter", 6);
	patternMinA = getDataD("Pattern Min Area",350); 
	patternMaxA = getDataD("Pattern Max Area", "Infinity");

	if (isRedo) {
		roiManager("Reset");
		
		segmentPatterns(startSlice, medianR);

		run("Analyze Particles...", "size="+patternMinA+"-"+patternMaxA+" display exclude clear add");		
		// Update all ROIs, keep only bottom left area
		nR = roiManager("Count");
		pointsX = newArray(nR);
		pointsY = newArray(nR);
		
		for(i=nR-1; i>=0; i--) {
			roiManager("Select",i);
			getSelectionBounds(x,y,w,h);
			roiManager("Delete");
			pointsX[i] = x;
			pointsY[i] = y+h;	
		}
		makeSelection("points", pointsX, pointsY);
		Roi.setName("Detected Traps");
		roiManager("Add");

	} 
		selectImage(ori);
}

function makeSTDImage(ori, start) {
		
		run("Z Project...", "start="+start+" projection=[Standard Deviation]");
		stdevi = getImageID();
		
		selectImage(ori);
		run("Z Project...", "start="+start+" projection=[Average Intensity]");
		avgi = getImageID();
		
		imageCalculator("Divide 32-bit create", stdevi, avgi);
		id = getImageID;
		
		selectImage(stdevi);
		close();
		selectImage(avgi);
		close();
		selectImage(id);
		
}
function filterPatterns() {

	
ori = getTitle();
	
	start = getStartSlice();
	
	idx = findRoiWithName("Selected Candidates");
	isRedo = true;
	if (idx != -1) {
		isRedo = getBoolean("Traps were already filtered. Re-run filtering?");
	}

	minSD 	   = getDataD("Pattern Min SD", 0.10); 
	maxSD 	   = getDataD("Pattern Max SD", 0.45);
	
		//Set the bounding box
	div_box_w = getDataD("Division Detection Box Width",40);
	div_box_h = getDataD("Division Detection Box Height",40 );
	div_box_x = getDataD("Division Detection Box X offset",5 );
	div_box_y = getDataD("Division Detection Box Y offset",38 );
	//SetData for pattern
	pattern_box_w = getDataD("Pattern Detection Box Width", 80 );
	pattern_box_h = getDataD("Pattern Detection Box Height", 80);
	

	if (isRedo) {
		
		if(roiManager("Count") == 2) {
			roiManager("Select", idx);
			roiManager("Delete");
			roiManager("Select", idx+1);
			roiManager("Delete");
		}		

		makeSTDImage(ori, start);
		res = getImageID();
		
		roiManager("Select", 0);
		
		getSelectionCoordinates(x,y);
		ind = newArray(0);
		
		k=0;
		xc = newArray(0);
		yc = newArray(0);
		
		for (i=0; i<x.length; i++) {
			makeRectangle(x[i], y[i]-pattern_box_h,pattern_box_w,pattern_box_h);
			//waitForUser;
			//roiManager("Add");
			getStatistics(area, mean);
			if ( inRange(mean, minSD, maxSD)) {
				//keep point
		
				xc = Array.concat(xc,x[i]);
				yc = Array.concat(yc,y[i]);
				makeRectangle(x[i]+div_box_x, y[i]-div_box_y, div_box_w,div_box_h);
				roiManager("Add");
				k++;
				ind = Array.concat(ind, k);
				
			}
		
		}

		makeSelection("point",xc,yc);
		Roi.setName("Selected Candidates");
		roiManager("Add");
		
		roiManager("Select", ind);
		roiManager("OR");
		Roi.setName("Position Masks");
		roiManager("Add");
		roiManager("Select", ind);
		roiManager("Delete");

		selectImage(res);
		rename(ori+" Relative STDDEV");
		run("Enhance Contrast", "saturated=0.65");
		close();
		
		selectImage(ori);
	}
}


function wasDetected(x,y) {
	selectImage("Detection Mask");
	if (getPixel(x,y) > 0) {
		return true;
	} else {
		return false;
	}
}

function getAngleDelta(angle1, angle2) {
	a = angle1 - angle2;
	if (a > 180)
		a -= 360;
	if (a < -180)
		a += 360;
	return a;
		
}
function getNearestPattern(x,y,xp,yp) {

	dmin = 1000;
	ip = -1;
	for(i=0; i<xp.length; i++) {
		d = distance(x,y,xp[i],yp[i]);
		if (d < dmin) {
			dmin = d;
			ip = i;
		}
	}

	return ip;
}

function distance(x1,y1,x2,y2) {
	d = sqrt(pow(x1-x2,2)+pow(y1-y2,2));
	return d;
}

function deleteRois(startI, endI) {
	toDel = newArray(endI-startI+1);
	for(i=startI;i<=endI;i++) {
			toDel[i-startI] = i;
	}
		roiManager("Select", toDel);
		roiManager("Delete");
}

function getTMin(frame, maxreturn) {
	tMin = frame-maxreturn;
	if (tMin <=0) {
		tMin = 0;
	}
	return tMin;
}

function findRoiWithName(roiName) {
	nR = roiManager("Count");

	for (i=0; i<nR; i++) {
		roiManager("Select", i);
		rName = Roi.getName();
		if (matches(rName, roiName)) {
			return i;
		}
	}
	return -1;
}

function getNeighbors(nThr, nMin) {
	// Check for neighbors
	// 1 find nearest pattern
	// 2 check neighbors
	setAutoThreshold(nThr+" dark");
	
	run("Analyze Particles...", "size="+nMin+"-Infinity show=Nothing display clear slice");
	nNeigh = nResults;
	
	return nNeigh;
	
}


function sanitizeImage() {
	getDimensions(x,y,c,z,t);
	if (z > 1 && t == 1) {
		run("Properties...", "channels="+c+" slices=1 frames="+z);
	}
	
	
}
function getTotalArea(nThr) {
	setAutoThreshold(nThr+" dark");
	run("Measure");
	ar = getResult("Area", nResults-1); 
	return ar;

}

function inRange(val, min, max) {
	if (val > min && val < max) {
		return true;
	} else {
		return false;
	}
}

 function toolName() {
 	return "Mitotic Division Analysis Tool";
 }

function flatFieldWizard() {
	run("Remove Overlay");
	setTool("rectangle");
	waitForUser("Draw a rectangle around the largest feature of your stack\nthen press OK");
	getVoxelSize(vx,vy,vz,U);
	getSelectionBounds(x, y, width, height);
	ffblur = getMax(width, height) / vx;
	showMessage("Pseudo FlatField blur sigma set to "+ffblur+" in calibrated units");
	setData("Pseudo Flatfield Blur", ffblur);

}

function patternWizard() {
	preProcessing();
	run("Remove Overlay");
	//close("\\Others");
	ori=getTitle();
	setBatchMode(true);
	getDimensions(x,y,c,z,t);
	medianR    = getDataD("Pattern Mask Median Filter", 6);
	roiManager("Reset");
	start = getStartSlice();
	
	segmentPatterns(start, medianR);
	
	setTool("rectangle");
	run("Analyze Particles...", "size=0-Infinity display exclude clear add");		
	
	renameRois("Pattern",3);
	setBatchMode(false);
	roiManager("Show All with labels");
	selectWindow("ROI Manager");
	waitForUser("On the ROi Manager, select all ROIs that match well formed patterns, then click OK");
	roiManager("Measure");
	nR = nResults;
	area = newArray(nR);
	for(i=0; i<nR;i++) {
		area[i] = getResult("Area", i);
	}

	Array.getStatistics(area, min, max, mean, stdDev);

	trapMinA   = mean-3*stdDev;
	trapMaxA   = mean+3*stdDev;
	
	setData("Pattern Min Area",trapMinA); 
	setData("Pattern Max Area", trapMaxA);
	selectImage(ori);
	close("\\Others");
	detectPatterns();
}

function patternROIWizard() {
	preProcessing();
	run("Remove Overlay");
	ori=getTitle();
	close(ori+" Traps Mask");
	
	medianR    = getDataD("Pattern Mask Median Filter", 6);
	
	trapMinA   = getDataD("Pattern Min Area", 350);
	trapMaxA   = getDataD("Pattern Max Area", "Infinity");

	//Set the bounding box
	getDataD("Pattern Detection Box Width", 30);
	getDataD("Pattern Detection Box Height", 30);
	getDataD("Pattern Detection Box X offset", 3);
	getDataD("Pattern Detection Box Y offset", 20);
		
	roiManager("Reset");
	start = getStartSlice();
	
	segmentPatterns(start, medianR);
	
	
	run("Analyze Particles...", "size="+trapMinA+"-"+trapMaxA+" display exclude clear add");
	mask = getTitle();
	// Make an averaged pattern
	nR = roiManager("count");
	for(i=0; i<nR;i++) {
		selectImage(mask);
		roiManager("Select",i);
		run("Duplicate...", "title=pattern"+i);
	}
	run("Images to Stack", "method=[Copy (center)] name=Stack title=pattern use");
	setTool("rectangle");
	run("Z Project...", "projection=[Average Intensity]");
	getDimensions(dx,dy,dc,dz,dt);
	getDimensions(x,y,c,z,t);
	setLocation(x, y, dx*10, dy*10);
	waitForUser("Modify the box to match the location where you expect to find cell divisions");
	getSelectionBounds(x,y,w,h);
	
	div_box_w = w;
	div_box_h = h;
	div_box_x = x;
	div_box_y = dy-y;
	
	pattern_box_w = dx;
	pattern_box_h = dy;
	
	
	//Set the bounding box
	setData("Division Detection Box Width", div_box_w);
	setData("Division Detection Box Height", div_box_h);
	setData("Division Detection Box X offset", div_box_x);
	setData("Division Detection Box Y offset", div_box_y);
		//SetData for pattern
	setData("Pattern Detection Box Width", pattern_box_w);
	setData("Pattern Detection Box Height", pattern_box_h);
		// Show result on mask
	close();
	close();
	
	for(i=0; i<nR;i++) {
		selectImage(mask);
		roiManager("Select",i);
		getSelectionBounds(x,y,w,h);
		makeRectangle(x+div_box_x, y+h-div_box_y, div_box_w,div_box_h);
		Roi.setName("Pattern - "+IJ.pad(i+1,3));
		roiManager("Update");
	}
}

function crowdWizard() {
	detectPatterns();
	run("Remove Overlay");
	run("Set Measurements...", "area mean centroid center fit shape area_fraction stack limit display redirect=None decimal=3");

	
	start = getStartSlice();

	ori = getTitle();
	
	makeSTDImage(ori,start);
	
	rename("STDDEV Image");
	
	pattern_w = getDataD("Pattern Detection Box Width", 80);
	pattern_h = getDataD("Pattern Detection Box Height", 80);
	
	idx = findRoiWithName("Detected Traps");
	if(idx == -1) {
		exit("No patterns found, please check the Pattern Detection Wizard!");
	}
	selectImage(ori);
	roiManager("Select", idx);
	
	getSelectionCoordinates(x,y);
	//roiManager("reset");
	
	for (i=0; i<x.length; i++) {
		makeRectangle(x[i], y[i]-pattern_h,pattern_w,pattern_h);
		Roi.setName("Pattern "+IJ.pad(i+1,3));
		roiManager("Add");
	}
	
	roiManager("Select", idx);
	roiManager("Delete");
	
	selectImage(ori);
	selectWindow("ROI Manager");
	roiManager("Show All with labels");
	waitForUser("On the ROi Manager, select all ROIs that have exactly one cell per pattern");
	nR = nResults;
	selectImage("STDDEV Image");
	roiManager("Measure");
	avg = newArray(nResults-nR);
	for(i=nR; i<nResults;i++) {
		avg[i-nR] = getResult("Mean", i);
	}
	Array.getStatistics(avg, min,max, mean, stddev);
	
	minSD = (1-0.3)*min;
	maxSD = (1+0.3)*max;
	
	setData("Pattern Min SD", minSD); 
	setData("Pattern Max SD", maxSD);

	for(i=0; i<roiManager("count");i++) {
		roiManager("Select", i);
		run("Measure");
		avg = getResult("Mean",nResults-1);
		if(inRange(avg,minSD,maxSD)) {
			run("Properties... ", "stroke=green width=02 fill=none");
		} else {
			run("Properties... ", "stroke=red width=02 fill=none");
		}
			roiManager("Update");
			
	}
	waitForUser("Green patterns will be kept for analysis, red patterns will be excluded");
	close("STDDEV Image");
	close(".* Traps Mask");
	selectImage(ori);
}

function mitosisWizard() {
	// Parameter Wizard
	
	run("Set Measurements...", "area mean min center fit shape stack limit display redirect=None decimal=5");
	ori = getTitle();
	run("Remove Overlay");
	getVoxelSize(vx,vy,vz,u);
	close("\\Others");
	
	// Correct Calibration
	
	
	// Laplacian Estimation
	setTool("line");
	
	waitForUser("Draw a Line Across the major axis of a Metaphase Plate");
	MAxis = getProfile();
	getSelectionCoordinates(Mx,My);
	
	
	// make line perpendicular to this one
	makePerpendicularLine(Mx, My);
	
	mAxis = getProfile();
	getSelectionCoordinates(mx,my);
	
	
	//  Fit a supergaussian through it
	paramm = fitSuperGaussian(mAxis);
	fwhmm = (2*sqrt(2*log(2))*paramm[3]);
	
	paramM = fitSuperGaussian(MAxis);
	fwhmM = (2*sqrt(2*log(2))*paramM[3]);
	
	major_axis_min = (1-0.3)* (fwhmM/2)/vx;
	major_axis_max = (1+0.3)* (fwhmM/2)/vx;
	
	minor_axis_min = (1-0.3)* (fwhmm/2)/vx;
	minor_axis_max = (1+0.3)* (fwhmm/2)/vx;
	
	min_axis_ratio = (1-0.3)* (fwhmM/fwhmm);
	max_axis_ratio = (1+0.3)* (fwhmM/fwhmm);
	
	//Estimated Laplacian = 1/2 of fwhmm
	est_laplacian = fwhmm/2;
	
	// Perform Laplacian and estimate threshold on Anaphase elements
	selectImage(ori);
	makeSelection("line",mx,my);
	slice_pos = getSliceNumber();
	setSlice(slice_pos+2);
	
	run("To Bounding Box");
	run("Enlarge...", "enlarge=5");
	run("Duplicate...", "title=Test");
	run("FeatureJ Laplacian", "compute smoothing="+est_laplacian);
	getDimensions(lx,ly,lc,lz,lt);
	
	xs = lx/2 - abs(mx[0]-mx[1])/2;
	ys = ly/2 - abs(my[0]-my[1])/2;
	xe = lx/2 + abs(mx[0]-mx[1])/2;
	ye = ly/2 + abs(my[0]-my[1])/2;
	
	makeLine(xs, ys, xe,ye);
	
	lP = getProfile();
	
	Array.getStatistics(lP, ana_min, ana_max, ana_mean, ana_stdDev);
	est_lap_thr = (1-0.8)*ana_min;
	
	// Estimate area of DNA during division
	// Apply threshold and analyse particles
	setThreshold(-100000, est_lap_thr);
	run("Analyze Particles...", "display clear");
	dna_area = 0;
	dna_xm = newArray(nResults);
	dna_ym = newArray(nResults);
	
	for(i=0; i<nResults;i++) {
		dna_area += getResult("Area", i);
		dna_xm[i] = getResult("XM", i);
		dna_ym[i] = getResult("YM", i);
	}
	dna_area /= nResults;
	
	dna_area_min = (1-0.3)*dna_area;
	dna_area_max = (1+0.3)*dna_area;
	
	dna_max_dist = (1+0.2) * distance(dna_xm[0],dna_ym[0], dna_xm[1],dna_ym[1]);
	
	
	//Now do the same for the area of the mitotic plate
	selectImage(ori);
	makeSelection("line",mx,my);
	
	setSlice(slice_pos);
	
	run("To Bounding Box");
	run("Enlarge...", "enlarge=5");
	run("Duplicate...", "title=Test");
	run("FeatureJ Laplacian", "compute smoothing="+est_laplacian);
	setThreshold(-100000, est_lap_thr);
	run("Analyze Particles...", "display clear");
	
	mp_area = getResult("Area",0);
	mp_min_lap = getResult("Min",0);
	
	mp_area_min = (1-0.3)*mp_area;
	mp_area_max = (1+0.3)*mp_area;
	mp_min_lap /= (1+0.70);
	
	setData("Laplacian Smoothing", est_laplacian);
	setData("Laplacian Threshold", est_lap_thr);
	
	setData("DNA Min Area", dna_area_min);
	setData("DNA Max Area", dna_area_max);
	setData("Division Max distance", dna_max_dist);
	setData("Mitotic Plate Minimal Laplacian", mp_min_lap);
	setData("Mitotic Plate Min Area", mp_area_min);
	setData("Mitotic Plate Max Area", mp_area_max);
	setData("Mitotic Plate Min Major Axis", major_axis_min);
	setData("Mitotic Plate Max Major Axis", major_axis_max);
	setData("Mitotic Plate Min Minor Axis", minor_axis_min);
	setData("Mitotic Plate Max Minor Axis", minor_axis_max);
	setData("Mitotic Plate Min Axis Ratio", min_axis_ratio);
	setData("Mitotic Plate Max Axis Ratio", max_axis_ratio);
	setData("Mitotic Plate Max Movement", 3*vx);
	setData("Mitotic Plate Max Frames to seek", 3);

	selectImage(ori);
	close("\\Others");
}

function renameRois(name, digits) {
	nR = roiManager("count");

	for(i=0; i<nR;i++) {
		roiManager("Select",i);
		roiManager("Rename", name+" - "+IJ.pad(i+1,digits));
		run("Properties... ", "  stroke=red width=2");
		roiManager("Update");
	}
}

function makePerpendicularLine(x,y) {
	angle = atan2(y[0]-y[1], x[0]-x[1])+PI/2;
	cx = x[0] + (x[1]-x[0])/2;
	cy = y[0] + (y[1]-y[0])/2;
	d = distance(x[0],y[0],x[1],y[1]);
	
	nx1 = cx - d/2 * (cos(angle));
	ny1 = cy - d/2 * (sin(angle));
	
	nx2 = cx + d/2 * (cos(angle));
	ny2 = cy + d/2 * (sin(angle));

	makeLine(nx1,ny1,nx2,ny2);
	print(angle, cx,cy,d, nx1,ny1,nx2,ny2);
	
}

function fitSuperGaussian(ydata) {
	n = ydata.length;
	xdata = Array.getSequence(n);
	Array.getStatistics(ydata, ymin, ymax, ymean, ystdDev)
	superString = "y = a + b * exp( 1.571*(-pow ( abs(x-c), e/2.0 ) ) / ( pow( d* 1.571 , e/2.0 ) ) )";
	init_parameter 	= newArray(5);
	init_parameter[0] = (ydata[0]+ydata[n-1])/2;
	init_parameter[1] = ymax-ymin;
	init_parameter[2] = xdata[n-1]/2;
	init_parameter[3] = xdata[n-1]/8;
	init_parameter[4] = 4;

	Fit.doFit(superString, xdata,ydata,init_parameter);
	Fit.plot;
	params = newArray(5);
	params[0] = Fit.p(0);
	params[1] = Fit.p(1);
	params[2] = Fit.p(2);
	params[3] = Fit.p(3);
	params[4] = Fit.p(4);
	
	return params;
}

function getMax(a,b) {
	if(a>b)
		return a;
	return b;
}

</codeLibrary>

<text><html><font size=4 color=#0C2981> All settings
<line>
<button>
label=Pattern
icon=noicon
arg=<macro>
patternSettings();
</macro>
</line>

<line>
<button>
label=Division Detection
icon=noicon
arg=<macro>
divisionDetectionSettings();
</macro>
</line>
<line>
<button>
label=Mitotic Plate
icon=noicon
arg=<macro>
mitoticPlateSettings();
</macro>
</line>



<line>
<button>
label=Toggle Debug Mode
icon=noicon
arg=<macro>
toggleDebug();
</macro>
</line>

<text><html><font size=4 color=#0C2981> Wizards
<line>
<button>
label=FlatField Wizard
icon=noicon
arg=<macro>
flatFieldWizard();
</macro>
</line>

<line>
<button>
label=Pattern Detection Wizard
icon=noicon
arg=<macro>
patternWizard();
patternSettings();
</macro>
</line>

<line>
<button>
label=Pattern ROI Wizard
icon=noicon
arg=<macro>
patternROIWizard();
patternSettings();
</macro>
</line>

<line>
<button>
label=Pattern Crowding Wizard
icon=noicon
arg=<macro>
crowdWizard();
patternSettings();

roiManager("Reset");
run("Select None");

//close("\\Others");
detectPatterns();

filterPatterns();

// find all division-like events
findDivisions();
	
// confirm those divisions
confirmDivisions();


</macro>
</line>

<line>
<button>
label=Mitosis Detection Wizard
icon=noicon
arg=<macro>
mitosisWizard();
divisionDetectionSettings();
mitoticPlateSettings();
</macro>
</line>

