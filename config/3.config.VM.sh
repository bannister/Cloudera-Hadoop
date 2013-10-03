#!/bin/sh
sudo R --no-save << EOF
install.packages(c('Rcpp', 'RJSONIO', 'itertools', 'digest', 'functional', 'plyr', 'stringr'), repos="http://cran.revolutionanalytics.com", INSTALL_opts=c('--byte-compile') )
EOF
wget --no-check-certificate https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr2_2.0.2.tar.gz
sudo R CMD INSTALL rmr2_2.0.2.tar.gz
sudo R CMD library(rmr2)
