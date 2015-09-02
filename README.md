# 03-the-redline
Private repo for The Redline

## File Descriptions

### app.R

This is our shinyapps.io source. So far this is just a playpen for very simple
EDA purposes, and a good testbed for our data handling code. It is easy to switch
on the hostname to use different directory structures for different team members
and for shinyapps.io.

### DownladBLSData.R

Some of the BLS data files are large enough that it is impractical to work with
them over the net. This R script downloads any that are missing from the target
directory.

### CompressBLSData.R

This reads in each of the (locally cached) BLS data files, builds a data.table
with proper variable names, and saves the result locally as a compressed .rda
file. It is easy to switch on the hostname to use different directory structures
for different team members.

### BLSDataExporation.Rmd

This loads the BLS data and displays for each file the data structure, summary,
head, and tail as BLSDataExploration.html.

### WatWIP.R

Please ignore this.
