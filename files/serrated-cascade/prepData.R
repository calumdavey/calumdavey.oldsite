# RDS-weighted figures for the diagram 
# Re-code the variables so that 'all-women' is the denominator 

## bl 
d_complete <- subset(d, d$wave!=0 & !is.na(d$hiv) & (d$h12<2 | is.na(d$h12)) 
                     & (d$h15a!=999 | is.na(d$h15a)) & !is.na(d$cut1000))
# Know positive, of all women 
d_complete$pos_know_all <- 0
d_complete$pos_know_all[d_complete$hiv==1 & d_complete$h12==1] <- 1
# On ART and know positive, of all women 
d_complete$pos_know_art_all <- 0
d_complete$pos_know_art_all[d_complete$pos_know_all==1 & d_complete$h15a==1]  <- 1
# On ART, know positive, and virally suppressed, of all women
d_complete$pos_know_art_supp_all <- 0
d_complete$pos_know_art_supp_all[d_complete$pos_know_art_all==1 & d_complete$cut1000==0] <- 1

## el 
dd_complete <- subset(dd, dd$wave!=0 & !is.na(dd$hiv) & (dd$h12<2 | is.na(dd$h12)) 
                      & (dd$h15a!=999 | is.na(dd$h15a)) & !is.na(dd$cut1000))
# Know positive, of all women 
dd_complete$pos_know_all <- 0
dd_complete$pos_know_all[dd_complete$hiv==1 & dd_complete$h12==1] <- 1
# On ART and know positive, of all women 
dd_complete$pos_know_art_all <- 0
dd_complete$pos_know_art_all[dd_complete$pos_know_all==1 & dd_complete$h15a==1]  <- 1
# On ART, know positive, and virally suppressed, of all women
dd_complete$pos_know_art_supp_all <- 0
dd_complete$pos_know_art_supp_all[dd_complete$pos_know_art_all==1 & dd_complete$cut1000==0] <- 1

c <- c("hiv", 
       "pos_know_all",
       "pos_know_art_all", 
       "pos_know_art_supp_all", 
       "cut1000")

bl <- matrix(, nrow = 0, ncol = 2)
el  <- matrix(, nrow = 0, ncol = 2)

for (j in c){
  bl <- rbind(bl,
              cbind( mean(summs(subset(d_complete, d_complete$intervention==0), j)),
                     mean(summs(subset(d_complete, d_complete$intervention==1), j))))
  el <- rbind(el,
              cbind( mean(summs(subset(dd_complete, dd_complete$intervention==0), j)),
                     mean(summs(subset(dd_complete, dd_complete$intervention==1), j))))
}

cc <- c(bl[1,1], el[1,1],  #bl-el HIV control 
        bl[1,2], el[1,2],  #bl-el HIV treatment 
        bl[2,1], el[2,1],  #bl-el know positive control
        bl[2,2], el[2,2],  #bl-el know positive treatment 
        bl[3,1], el[3,1],  #bl-el on ART control
        bl[3,2], el[3,2],  #bl-el on ART treatment 
        bl[4,1], el[4,1],  #bl-el suppressed control
        bl[4,2], el[4,2])  #bl-el suppressed treatment 

data <- data.frame(year= rep(c(2013,2016), times=8),
              outcome=rep(c('HIV','Know pos.','On ART','Supp.'), each=4),
              arm=rep(c(0,1), each=2, times=4),
              p=round(cc,3))

cc <- cbind(c(0.01,.1,0.01,.1,
              .11,.2,.11,.2,
              .21,.3,.21,.3,
              .31,.4,.31,.4), 
            cc)
pt <- c(1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19)

# Create the plot and the points 
plot(cc, ylim=c(0,1), xlim=c(0.01,.71), yaxt="n", xaxt="n", pch=pt, bty="n",
     xlab="", ylab="Means of RDS-adjusted proportions in all women", cex.lab=.6)

# Add the sloping lines 
for (r in c(1,3,5,7,9,11,13,15)){
  lines(cc[r:(r+1),1], cc[r:(r+1),2], type="l", lwd=1.7)
}

#  Add the vertical lines
for (r in c(1:16)){
  lines(c(cc[r,1],cc[r,1]),c(0,cc[r,2]), lwd=.7)
}

# Add horizontal line at bottom
lines(c(0.01,.71), c(0,0))

# Add the 90:90:90 lines
nnn <- c(mean(bl[1,1:2])*.9,          # First 90 for diagnosis 
         mean(bl[1,1:2])*.9*.9,       # Second 90 for treatment  
         mean(bl[1,1:2])*.9*.9*.9)    # Third 90 for suppression 

lines(c(.11,.2), c(nnn[1],nnn[1]), lty=5, lwd=.7)
lines(c(.21,.3), c(nnn[2],nnn[2]), lty=5, lwd=.7)
lines(c(.31,.4), c(nnn[3],nnn[3]), lty=5, lwd=.7)

text(.2-.01,nnn[1]+.02,labels="90%", cex=.5)
text(.3-.01,nnn[2]+.02,labels="81%", cex=.5)
text(.4-.01,nnn[3]+.02,labels="73%", cex=.5)

# Add the dates 
lines(c(cc[1,1],cc[1,1]),c(cc[1,2],cc[1,2]+.08), lty=3, lwd=.7)
lines(c(cc[2,1],cc[2,1]),c(cc[2,2],cc[2,2]+.08), lty=3, lwd=.7)

text(cc[1,1]+0.0125,cc[1,2]+.1,labels="2013", cex=.5)
text(cc[2,1]+0.0125,cc[2,2]+.1,labels="2016", cex=.5)

# Add 'squeeze' diagram 
left <- .5
lines(c(left,left,left+.1,left+.1,left),c(0,1,1,0,0),lwd=.3) # Make bound for outcome chart control
lines(c(left+.11,left+.11,left+.11+.1,left+.11+.1,left+.11),c(0,1,1,0,0),lwd=.3) # Make bound for outcome chart intervention
# Control lines 
lines(c(left,left+.1), c(bl[1,1], el[1,1]),lwd=2) 
lines(c(left,left+.1), c(bl[1,1]-bl[5,1], el[1,1]-el[5,1]),lwd=2)
# Intervention lines 
lines(c(left+.11,left+.11+.1), c(bl[1,2], el[1,2]),lwd=2)
lines(c(left+.11,left+.11+.1), c(bl[1,2]-bl[5,2], el[1,2]-el[5,2]),lwd=2)

# Add points 
# Control points 
points(c(left,left+.1), c(bl[1,1], el[1,1]))
points(c(left,left+.1), c(bl[1,1]-bl[5,1], el[1,1]-el[5,1]))
# Intervention points
points(c(left+.11,left+.11+.1), c(bl[1,2], el[1,2]), pch=19)
points(c(left+.11,left+.11+.1), c(bl[1,2]-bl[5,2], el[1,2]-el[5,2]), pch=19)

ap <- c(0,.2,.4,.6,.8,1)
axis(2, at=ap, lab=paste0(ap * 100, "%"), las=TRUE, cex.axis=0.6)

text(c(.05, .15, .25, .35, .55,.65),c(-.0193), 
     labels=c("HIV +ve", "Know +ve", "On ART", "vl<1000c/ml", "S. Only", "Enh. S."), cex=.6)

text(c(left+.05),
     c(bl[1,1]+0.1,.5,.45,bl[1,1]-bl[5,1]-0.1,bl[1,1]-bl[5,1]-0.15),
     c("HIV-ve", "vl \u2265 1000", "c/ml", "vl<1000","c/ml"), cex=.5)
text(c(left+.11+.05),
     c(bl[1,1]+0.1,.5,.45,bl[1,1]-bl[5,1]-0.1,bl[1,1]-bl[5,1]-0.15),
     c("HIV-ve", "vl \u2265 1000", "c/ml", "vl<1000","c/ml"), cex=.5)

legend(0,.9,c("Sisters only arm", "Enhanced Sisters arm"),pch=c(1,19), bty="n", cex=.5)