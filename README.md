# assignment03_LimpetShellEvolution

## Extracting data from 3D scans of limpet shells to test for fisheries-induced evolution

My lab has been studying the evolution of limpets in Hawaii.  They are a local delicacy and are under intense harvesting pressure.  We are interested in the selective pressures applied by overharvesting and how it affects the evolution of phenotypes.  

We found that shell surface area is associated with human harvesting and want to use 3d scans of the limpet shells to more precisely test of effects of harvesting on phenotype. 

![alt text](https://github.com/tamucc-comp-bio-2020/classroom_repo/blob/master/lectures/Week03_files/3Dscan_limpetShell.PNG)

The image above is a rendered 3d scan, but the data file is in [STL](https://en.wikipedia.org/wiki/STL_%28file_format%29) format.  An stl file is obtuse and not the easiest for a human to read.  Consequently, a tool to extract information from stl files, [admesh](https://admesh.readthedocs.io/en/latest/#), was created as a master's thesis.  I found this program and used it to extract the surface areas of the shells.  Note that I did also have to manipulate the stl files and clip off the bottom surface covering the shell aperature using a bash tool that I made (not included in this assignment).  

The output of admesh is not tidy and I had to make a tool to wrangle it, `admesh2tsv.bash`. We are going to use and modify this script


--- 

## Description of Assignment

* Clone the repository for this assignment to your home dir in your terminal. 
   * make sure that you have set up your ssh security key (see Lecture 0) and use the "ssh" link when cloning

* Ensure that the `admesh2tsv.bash` script works by running it on the `admesh.out` data. This script converts the output of [`admesh`](https://admesh.readthedocs.io/en/latest/), a unix command to extract information from 3D scans stored in `stl` files, into a "tidy" data file.

```
#this script takes output from admesh and makes a tidy TSV file

#to run:
#bash admesh2tsv.bash <admesh output file> 

bash admesh2tsv.bash admesh.out

bash admesh2tsv.bash admesh.out > admesh.tsv
```

* Complete the requested updates to the `admesh2tsv.bash` (see below)

* I HIGHLY recommend that you use your GUI text editor (NotePad++ or BBedit) to edit the script.
    * you can copy the text in your script from your terminal to your text editor, make edits in the text editor, then copy back to the terminal

* I recommend testing for proper function and troubleshooting as necessary after each change you make to the script

* I also recommend that you copy and paste the lines of code you are editing/testing directly into the terminal
    * once you have confirmed that the script works, line by line, then you can try to run the whole script

* You may work in groups but each student must submit their own work.

### Structure of Script
The `admesh2tsv.bash` script is functional, but hard to read and poorly commented.  We can employ variables to improve the readability of the script and reorganize the comments to improve it for future users.

The script can be confusing at first, but it only really does two things.  

1. It employs `cat` to join a header with the tidy data and saves that into a file which is stored in the outputFile which is stored in the variable `$TIDYDATAFILE` which is provide as an argument at the command line.

   ```bash
   #this is pseudo code, the (), <, and > are required and do something
   cat <(header) <(tidy data) > outputFile
   ```

2. It extracts data from the `admesh.out` file in columns and joins the columns using `paste` to make the tidy data

   ```bash
   #this is pseudo code, the (), <, and > are required and do something
   paste <(3D stl file names) <(Min and Max X) <(Min and Max Y) <(Min and Max Z) <(Number of Facets) <(shell volume) <(shell surface area)
   ```

To be efficient, the intermediary steps are not saved into files and so, the business end of this script is one long pipeline and the escape character `\ ` is used to make it more readable by separating each component by line.

   ```bash
   # this is pseudo code
   cat <(header) \
   <( \
   tidy data
   \)


   # this is same pseudo code on 1 line
   cat <(header) <(tidy data) 
   ```

Expanding the "tidy data" in the previous pseudo code block (each line is creating a column of data):

   ```
   # this is pseudo code that describes the main portion of the script
   cat <(header) \
   <(\
     paste <(3D stl file names) \
       <(Min and Max X) \
       <(Min and Max Y) \
       <(Min and Max Z) \
       <(Number of Facets) \
       <(shell volume) \
       <(shell surface area) \
   )

   # this is same pseudo code on 1 line
   cat <(header) <(paste <(3D stl file names) <(Min and Max X) <(Min and Max Y) <(Min and Max Z) <(Number of Facets) <(shell volume) <(shell surface area)) > output file
   ```

And here is the full bash code block for comparison to the pseudo code blocks above

   ```bash
   cat <(echo -e FileName'\t'MinX'\t'MaxX'\t'MinY'\t'MaxY'\t'MinZ'\t'MaxZ'\t'FacetsBefore'\t'FacetsAfter'\t'Volume'\t'SurfArea) \
   <(\
     paste -d '\t' <(grep '^Input file' $INPUTFILE | sed 's/ //g' | sed 's/Inputfile://g') \
       <(grep '^Min X' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]X=//g' | tr "," "\t") \
       <(grep '^Min Y' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Y=//g' | tr "," "\t") \
       <(grep '^Min Z' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Z=//g' | tr "," "\t") \
       <(grep '^Number of facets' $INPUTFILE |  sed 's/Number of facets  *: *//g' | sed 's/  */\t/g') \
       <(grep 'Volume' $INPUTFILE |  sed 's/Number of parts *:.*Volume *: *//g') \
       <(grep 'Surface area' $INPUTFILE |  sed 's/Degenerate facets *:.*Surface area *: *//g')\
   ) 

   #this is not easily readable on 1 line
   ```


### Requested Updates
Generally, your task is to take each of the arguments passed to cat and paste, save them into variables that are logically named and defined after `TIDYDATAFILE=$2` and before the line beginning with `cat`.  Then use those variables as arguments passed to `cat` and `paste`.  The tricky part is that variables don't store tabs or ends of lines; those will be converted to spaces. You will have to use `echo`, `tr`, and sometimes `paste`, in that order, to convert the variables back into a tab delimited header row and columns within the arguments passed to `cat` and `paste`. Prior to each line you add or modify, add a comment that describes what is happening in the next line of code. Troubleshoot your changes until the script works.

*Step by Step*
1. Rather than making the header inside the first argument for `cat`, after the line with `TIDYDATAFILE=$2`, insert a comment (e.g `# create header row and save to variable`).  In the following line, make a variable called HEADER and set it equal to the code that specifies the header.  Then pass the variable `$HEADER` to `cat` as the first argument.  Make sure the script works before going to step 2.  If you get stuck, post to our team on github.  I'll show you this one, the you will do the rest:
```bash
# read in arguments from the command line
INPUTFILE=$1
TIDYDATAFILE=$2

# create header row and save to variable
HEADER=$(echo -e FileName'\t'MinX'\t'MaxX'\t'MinY'\t'MaxY'\t'MinZ'\t'MaxZ'\t'FacetsBefore'\t'FacetsAfter'\t'Volume'\t'SurfArea)

# create tidy data file
cat <(echo $HEADER | tr " " "\t") \
<(\
  paste -d '\t' <(grep '^Input file' $INPUTFILE | sed 's/ //g' | sed 's/Inputfile://g') \
    <(grep '^Min X' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]X=//g' | tr "," "\t") \
    <(grep '^Min Y' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Y=//g' | tr "," "\t") \
    <(grep '^Min Z' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Z=//g' | tr "," "\t") \
    <(grep '^Number of facets' $INPUTFILE |  sed 's/Number of facets  *: *//g' | sed 's/  */\t/g') \
    <(grep 'Volume' $INPUTFILE |  sed 's/Number of parts *:.*Volume *: *//g') \
    <(grep 'Surface area' $INPUTFILE |  sed 's/Degenerate facets *:.*Surface area *: *//g')\
) > $TIDYDATAFILE

```

2. Following the style set in 1, save the first argument for paste, eg <(3D stl file names), to a variable named `FileNames` and use the variable `$FileNames` to pass the single column of data in the first argument to paste. Save changes and make sure this works (do this after every step).

3. Following the style set in 1, save the second argument for paste, eg <(Min and Max X), to a variable named `MinMaxX` and use the variable `$MinMaxX` to pass the 2 columns of data in the second argument to paste. Again, note that tabs and lines are removed when saving into a variable. We learned in Lecture2 how to replace spaces with line feeds (end of line) and in Lecture3 how to take a single column of data. 

4. Repeat for each argument to paste

5. Clean up the old commenting that precedes the variables being set by removing unneccessary or duplicated comments.

6. Modify the script to add at least one more column of data (extracted from the admesh.out file) to the final tidy data file.

### To `push` your changes to your repository on GitHub, and thus submit the assigment, do the following

* change directories to the directory for this assignment
* type the following:
```
git add *
git commit -m "updating my assignment"
git push origin master
```

Note that 
* you can change the `commit` message to whatever you want (the part in quotations, but keep it brief
* you will have to provide your github username and password for the `push` to `origin master`
