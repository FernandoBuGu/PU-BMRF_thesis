#script to compute Area under the curve (AUC) for protein function prediction of a GO term using Yiannis code. 

    #MSc thesis bioinfomratics WUR. Protein function prediction for poorly annotated species.
    #Author: Fernando Bueno Gutierrez
    #email1: fernando.buenogutierrez@wur.nl
    #email2: fernando.bueno.gutie@gmail.com


old_start <- Sys.time()
args<-commandArgs(T)
library(Matrix);
library(methods) #This is required when running Rscript
library(plyr)
library(foreach)
library(doParallel)
source("/home/bueno002/pearsons_ready/bmrf_functions.R");
source("/home/WUR/bueno002/chickens035/validation_functions_chickens.R")



k=10; no_R=20; noit_GS=30


#Parameters to choose
minGOsize=20
maxGOsize=0.1
only_EES_BP=F
domainMAX=0.9
domainMIN=20

subset=F
all=T							#Choose [1,2,3,4,5,F], depending on folders: "From_gitHub/large_coex/additional_inputs_and_plots/fileS/" 
reduce="F"		#amg,oa,epp,epn,enn   associationsof my go; other associations; edges of proteins of my go; other edges	
RMO=0 #Whether some random assoications will be removed. This is to test the importance of the data. RMO=0 means no data is removed.
tissue=F #int form 1 to 5, value F is also allowed.
		
PE<-c(0.6,0.5,0.2,0.1) #sequence of Perason correlation cthresholds considered.
					

P=0.2 #Pearson correlation considered in first place.

pearson<-as.numeric(P)
name_source<-paste("/home/bueno002/pearsons_ready/validation_functions_",pearson,".R",sep="")
source(name_source)

name<-paste("/home/bueno002/pearsons_ready/goes_",pearson,sep="")
GOES<-read.table(name)

name_save<<-paste("pearson_",pearson,sep="")

SE<-seq(1,dim(GOES)[1])



new_function<-function(GO){
#Retuns AUC for a given GO term. The result corresponds to one specific perason correlation threshold

#In: 
    #GO: int, index of the GO term in the "GOES" file

#Out:
    #result_AUC: AUC for the GO term "GO"

    go<<-as.character(GOES$V1[GO])

    loaded<<-return_L_m(subset=subset,minGOsize=minGOsize,maxGOsize=maxGOsize,only_EES_BP=only_EES_BP)
    result_AUC<-AUCf(go,k,all=all,noit_GS,0,0,domainMAX,domainMIN)
    return(result_AUC)
}



# call the function for each Pearsicn correlation considered
for(i in SE){



    aUC<-c()
    for(I in 1:k){
        w<-new_function(i)
        print(w)
        aUC<-append(aUC,w)}



    meanAUCSs<-mean(aUC,na.rm=T)
    sdAUCSs<-sd(aUC,na.rm=T)



    #write in file
    column_name<-as.character(c("'go_number'","'meanAUC'","'sdAUC'"))
    #column<-as.character(c(go,sum(my_GO_only),sum(my_GO_only_valid),dim(epp_myGO)[1],dim(epp_myGO_val)[1],dim(epn_myGO)[1],dim(epn_myGO_val)[1],sum(dim(epp_myGO)[1],dim(epn_myGO)[1]),sum(dim(epp_myGO_val)[1],dim(epn_myGO_val)[1]),depth,AUC))
    column<-as.character(c(go,meanAUCSs,sdAUCSs))


    out.file <- paste("/home/bueno002/pearsons_ready/AUC/",name_save,".txt", sep="")
    if(file.exists(out.file)){
        DF<-data.frame(column)
        DF<-t(DF)
        write(DF, file=out.file,ncolumns=length(column),append=T)
    } else {
        DF<-data.frame(column_name)
        DF<-t(DF)
        DF<-rbind(DF,column)
        write.table(DF, file=out.file, col.names = F, row.names = F, quote = F, sep="\t")
    }


    new_end <- Sys.time() - old_start
    print(new_end)
    print("finished_infochicken!")
}




