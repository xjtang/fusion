New Fusion 
======

v1.3.2 beta

Near Real-Time Monitoring of Land Cover Disturbance by Fusion of MODIS and Landsat Data

About
------

The Fusion model is a set of functions written in MATLAB for combining remote sensing images from MODIS and Landsat to detect land cover change in near real time (see Xin et al., 2013 for more details on Fusion). The core of the original Fusion model is to predict MODIS swath observations based on synthetic Landsat ETM image from the CCDC model (see Zhu & Woodcock, 2014 for more details on CCDC; see Zhu et al., 2015 for more details on synthetic images. The New Fusion model presented here include a brand new fusion time series concept and a associated change detection component.

The original Fusion model is developed by Qinchuan Xin at Boston University (version 1-6). I modified Fusion version 6 after I took over this project in May, 2014. The New Fusion model (or Fusion v6.1 and higher) inherited most of the predicting component in the original Fusion model with monification to support new workflow and data structure. A brand new fusion time series concept and change detection component is added to complete the land cover change detecting process. See comments in each script for details of new components or specific changes that has been added or created.

Current version of the New Fusion model supports MODIS Terra/Aqua in 500/250m resolution with the option of BRDF correction. Landsat synthedit images need to be prepared before running this model. Various output indicating areas of land cover change can be generated using this model. A brand new fusion tool in open source language is under development (follow xjtang/openfusion).

Content
------

**Main Scripts:**  

fusion_Run - The wrap-up function to run a select Fusion step.   
fusion_Inputs - Intilize the main input structure for other processes  
fusion_BRDF - Generate BRDF correction coefficients  
fusion_SwathSub - Create subset of the MODIS swath based on geolocation of Landsat images  
fusion_Cloud - filter out extremely cloudy data  
fusion_Fusion - The main fusion process  
fusion_BRDFusion - The main fusion process with BRDF correction  
fusion_Dif - Calculate difference image and change image  
fusion_WriteHDF - Write the final outputs to new HDF files  
fusion_WriteETM - Reproject and write difference image to ETM image  
fusion_Cache - Cache all the fusion time series images into matlab file  
fusion_Change - Detect change in the fusion time series  
fusion_GenMap - Generate change map in ENVI format  
compile - Function to compile the model  
config - Example of a configuration file (optimized for a study site in Amazon)  

**Supplimental Scripts:**  

core - some key functions that will be used by the main scripts  
ext - some external functions written by other authors  
bash - bash scripts for running fusion in qshell  
mcc - compiled version of the mode.  
doc - documentations of the model  
tool - some small tools for pre- / post- fusion analysis  
**some tools have not been tested since the last majot update.** 

Data
------

**Required:**  

MOD09 - MODIS Terra Surface Reflectance 5m L2 Swath  
ETMSYN - Synthetic Landsat ETM image   

**Optional:**  

MOD09GA - MODIS Terra Surface Reflectance Daily L2G 500m and 1km Gridded Data  
MCD43A1 - MODIS BRDF/Albedo Model Parameters Product  

Instruction
------

**Preparing**  

- Download required input data and allocate enough disk space for output  
- Organize all input data in one folder with original folders and file names (such as MOD09, MOD09GA)  
- Clone (or pull) the fusion repo. to your server or local computer  
- Compile the model if necessary  
- Copy and customize the configuration file  

**To run fusion step by step**  

- Launch MATALB
- Run each step of the fusion process one by one using fusion_Run.m with the correct inputs.

**To run fusion on a server (using the server of Boston University as an example)**  

- Log on to server  
- Open a Bash terminal  
- Use fusion_Batch.sh to submit jobs to run specific fusion process  

A complete fusion process follows these steps: Inputs -> BRDF -> SwathSub -> Cloud -> Fusion/BRDFusion -> Dif -> WriteHDF -> WriteETM -> Cache -> Change -> GenMap

Detailed documentation on how to run the New Fusion model is also available [here](/doc).

Dependencies
------

**For main functions:**    
MATLAB (r2013a or higher)  
gdal (1.10.0 or higher)  
hdf (4.2.5 or higher)  
bash (4.1.2 or higher)  

**For compiled version:**  
MATLAB Compiler Runtime (8.1/2013a or higher)

**For some minor functions:**  
R (2.15.2 or higher)  
RCurl Package (1.95-4.3 or higher)  
R.matlab Package (3.1.1 or higher)  
png Package (0.1-7 or higher)  

Publications
------

Xin, Q., Olofsson, P., Zhu, Z., Tan, B., & Woodcock, C. E. (2013). Toward near real-time monitoring of forest disturbance by fusion of MODIS and Landsat data. Remote Sensing of Environment, 135, 234-247.  

Zhu, Z., & Woodcock, C. E. (2014). Continuous change detection and classification of land cover using all available Landsat data. Remote Sensing of Environment, 144, 152-171.  

Zhu, Z., Woodcock, C. E., Holden, C., & Yang, Z. (2015). Generating synthetic Landsat images based on all available Landsat data : Predicting Landsat surface reflectance at any given time. Remote Sensing of Environment, 162, 67–83.  

