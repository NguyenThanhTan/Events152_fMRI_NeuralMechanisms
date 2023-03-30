library(RNifti);  # volumes

rm(list=ls());  
options(warnPartialMatchDollar=TRUE);

out.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/parcel_images/Schaefer400x7/";

in.img <- readNifti("/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/Schaefer2018_400x7_94x111x94.nii.gz");
under.img <- readNifti("/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/HCP_S1200T1w_94x111x94.nii.gz");      # anatomy for underlay



for (pid in 1:400) {   # pid <- 1;
  jpeg(paste0(out.path, "Schaefer400x7_p", pid, ".jpg"), bg='black');   # path and name of jpeg to create
  
  # figure out which slice to plot for this parcel
  inds <- which(in.img == pid, arr.ind=TRUE);  # pick slice with most parcel values to plot.
  ux <- unique(inds[,3]);  # find mode (http://stackoverflow.com/questions/2547402/is-there-a-built-in-function-for-finding-the-mode)
  do.slice <- ux[which.max(tabulate(match(inds, ux)))];
  
  
  image(under.img[,,do.slice], col=gray((0:64)/64), xlab="", ylab="", axes=FALSE, useRaster=TRUE);  # draw the underlay
  plt.data <- in.img[,,do.slice];   # get the values for the overlay
  plt.data2 <- array(NA, dim(plt.data));  # get rid of everything else
  plt.data2[which(plt.data == pid)] <- 1;  # just this parcel, this slice
  image(plt.data2, col='red', useRaster=TRUE, add=TRUE);      # draw the overlay
  
  #ttl <- paste0(sub.id, " ", subcort.tbl$parcel.label[pid], " ", subcort.tbl$hemisphere[pid], " (#", subcort.tbl$HCP.label[pid], ")");
  ttl <- paste("Schaefer parcel", pid);
  mtext(side=3, text=ttl, line=0.1, cex=1.5, col='white');
  #text(x=-0.05, y=0.94, labels=ttl, col='white', pos=4, cex=0.8);        # title
  #text(x=-0.05, y=0.94, labels=paste0(nrow(inds), " voxels"), col='orange', pos=4); 
  dev.off();   # release the jpeg image file
}