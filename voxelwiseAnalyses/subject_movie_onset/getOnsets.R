# DCL Events152_fMRI_NeuralMechanisms
# started 8 September 2022 by Jo
###############################################################################################################################################
###############################################################################################################################################
# get the movie onsets for each person, run. These are from .csv files stored in box /exp152_fMRIneuralmechanisms/data/ 
# (https://wustl.app.box.com/folder/137241546772) named like e152024_exp152_fMRI_seq4_2.4.1_2021_Nov_13_1228.csv
# where the _seq4_ bit gives the run number, followed by the movie name.

# From Matt Bezdek's 8 September 2022 email: (Psychopy) started with an instruction slide, then a manual space press was recorded and a
# screen saying something like "wait for scanner to start" appeared that waited for a "t" pulse from the scanner to proceed to the fixation
# crosses and then the movie. So the Movie.started time is the onset in seconds relative to when the program first opened. To get the Movie start
# relative to the scanner onset (in seconds), I think you need to take "Movie.started" minus the first value from the column "cross_fixation.started".
# in the event of multiple output files, the one with the most recent timestamp in the name is the correct scan."

# So, just need four onsets for each person one per run. Get 'em from box, and store in a single file.

library(boxr);    # https://github.com/r-box/boxr

rm(list=ls());

box_auth();   # initiate the link to box. 
anc.pre <- "137241546772";   # box ID for /exp152_fMRIneuralmechanisms/data/

out.path <- "d:/svnFiles/eventBoundaries/events152/";

# the participants have two IDs, one in e152 files (including the box event timing files), and one in the fmriprep
# output. This gives both, in the same order. From the https://wustl.app.box.com/file/836753376475 subdict
sub.ids <- c(paste0("0", 1:9), 10:47);  # as named in the fmriprep output
sub.lbls <- c('e152003','e152004','e152007','e152008','e152009', 'e152010','e152011','e152013','e152014','e152015',
              'e152016','e152017','e152018','e152019','e152020', 'e152021','e152022','e152023','e152024','e152025',
              'e152026','e152027','e152028','e152029','e152030', 'e152031','e152032','e152033','e152034','e152035',
              'e152036','e152037','e152038','e152039','e152040', 'e152041','e152042','e152043','e152044','e152045',
              'e152046','e152047','e152049','e152050','e152051', 'e152052','e152053');  
run.ids <- 1:4;
run.lbls <- c("1.2.3", "6.3.9", "3.1.3", "2.4.1");   # movie names in run.ids order

out.tbl <- data.frame(array(NA, c(length(sub.ids), 6)));
colnames(out.tbl) <- c("sub.id", "sub.lbl", paste0(paste0("run", run.ids, "_"), run.lbls));
for (sid in 1:length(sub.ids)) {    # sid <- 1
  out.tbl$sub.id[sid] <- paste0("sub-", sub.ids[sid]);
  out.tbl$sub.lbl[sid] <- sub.lbls[sid];
  for (rid in 1:length(run.ids)) {   # rid <- 1;
    #e152024_exp152_fMRI_seq4_2.4.1_2021_Nov_13_1228.csv
    
    fname <- paste0(sub.lbls[sid], "_exp152_fMRI_seq", run.ids[rid], "_", run.lbls[rid], "_");     # start of filename, without extension
    boxr.in <- as.data.frame(box_search(paste0('"', fname, '"'), type='file', content_types="name", file_extensions='csv', ancestor_folder_ids=anc.pre)); 
    
    # will return multiple files if run started more than once (we want the most recent), plus files ending in trials.csv.
    if (nrow(boxr.in) > 0) {   # got some, so need to see if any are the right one.
      tmp <- boxr.in$name;  # just the names
      tmp <- tmp[-grep("trials", tmp)];  # take out any with "trials" in the name.
      
      if (length(tmp) > 1) {   # still too many; want the one with the biggest timestamp, which is last 4 characters
        nums <- rep(NA, length(tmp));
        for (i in 1:length(tmp)) {   # i <- 1;
          nums[i] <- as.numeric(substr(tmp[i], nchar(tmp[i])-7, nchar(tmp[i])-4));   # parse out the timestamp
        }
        tmp <- tmp[which(nums == max(nums))];   # just keep the biggest
      }
      if (length(tmp) == 1) {   # found it!
        ind <- which(boxr.in$name == tmp);
        if (length(ind) == 1) {   # should only be one .... but double-check
          in.tbl <- box_read_csv(boxr.in$id[ind], fread=FALSE);    # read in the file from box
        } else { stop(paste0("length(ind) != 1  sub-", sub.ids[sid], " run", run.ids[rid])); }
      } else { stop(paste0("length(tmp) != 1  sub-", sub.ids[sid], " run", run.ids[rid])); }
    } else { stop(paste0("nrow(boxr.in) not > 0  sub-", sub.ids[sid], " run", run.ids[rid])); }
    
    # actually get the times
    start.time <- min(in.tbl$cross_fixation.started, na.rm=TRUE);
    if (!(start.time > 0)) { stop(paste0("!(start.time > 0)  sub-", sub.ids[sid], " run", run.ids[rid])); }
    
    movie.time <- in.tbl$Movie.started[which(!is.na(in.tbl$Movie.started))];
    if (length(movie.time) != 1) { stop(paste0("length(movie.time) != 1  sub-", sub.ids[sid], " run", run.ids[rid])); }
  
    if (movie.time >= start.time) { out.tbl[sid, (rid+2)] <- movie.time - start.time; }
    
    rm(movie.time, start.time, boxr.in, tmp);   # cleanup
  }
}
write.table(out.tbl, paste0(out.path, "e152onsets.txt"));

# looks like https://wustl.app.box.com/file/963885633869 is misnamed: e152053_exp152_fMRI_seq3_3.1.3_2022_May_28_1005_3.csv

# Error: length(tmp) != 1  sub-47 run3
# In addition: Warning message:
#   In as.numeric(substr(tmp[i], nchar(tmp[i]) - 7, nchar(tmp[i]) -  :
#                          NAs introduced by coercion


###############################################################################################################################################

