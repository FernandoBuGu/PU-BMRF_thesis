#Script to create the files required for the extraction of the RN. Mainly, clean the network file and create the similarity matrix for the GO terms.
#the script can be run in ALTSCHUL, since this server has the "GOSim" package installed.

    #MSc thesis bioinfomratics WUR. Protein function prediction for poorly annotated species.
    #Author: Fernando Bueno Gutierrez
    #email1: fernando.buenogutierrez@wur.nl
    #email2: fernando.bueno.gutie@gmail.com



#1) create cleaned network file (before: 12637 genes, now: 12424), and genes.tsv
#2) create file to choose selected GO terms for analysis. 138 GO terms paass the filter. We selecte further 30 non-similar ones.


library("Matrix")

#1) clean network file (before: 12637 genes, now: 12425)
source("/home/bueno002/chickens035/bmrf_functions.R");
go<-read.table("/home/bueno002/chi35_1GO/additional/rbind_upvalid_upNONvalid_035")
network<-read.table("/home/bueno002/chi35_1GO/additional/big_topless035_old10_october.tsv")
network<-network[2:7590726,]#Since it had a header

genes<-unique(append(as.character(network$V1),as.character(network$V2)))
genes_no_go<-genes[!genes %in% as.character(go$V1)]


#remove genes that appear in network less than 2 times. minimum 2 times, as it is not properly trimmed (i.e. "domain", or "protein" appear as genes)
genes_for_table<-append(as.character(network$V1),as.character(network$V2))
table_genes_network<-table(genes_for_table)
genes_remove<-names(table_genes_network)[table_genes_network<3]
length(genes_remove)
    #check that they do not appear in the GO file
genes_remove<-genes_remove[!genes_remove %in% as.character(go$V2)]
length(genes_remove) #this length and above are same, so no problem in removing
network<-network[!as.character(network$V1) %in% genes_remove & !as.character(network$V2) %in% genes_remove,]
network<-network[!as.character(network$V1) %in% c("ribosomal","MARCO") & !as.character(network$V2) %in% c("ribosomal","MARCO"),] #Sin

genes<-unique(append(as.character(network$V1),as.character(network$V2)))
length(genes) #new #of genes



write.table(genes, file="genes12424.tsv", col.names = F, row.names = F, quote = F, sep="\t")
write.table(network, file="big_topless035.tsv", col.names = F, row.names = F, quote = F, sep="\t")





#2) select the GO terms for analysis
minGOsize=20 #20 valid
maxGOsize=0.1 #0.1% of 12425. We r not intereted in predicting too wide Go terms
A = loadSingleNet(network)
maxGOsize=maxGOsize*nrow(A) #1245

dim(go)
go<-go[go$V1 %in% network$V1 | go$V1 %in% network$V2,]
dim(go)
write.table(go, file="/home/bueno002/chi35_1GO/additional/go_complete.tsv", col.names = F, row.names = F, quote = F, sep="\t")#for the second part of an
go<-go[go$V3=="valid",]
write.table(go, file="go_valid.tsv", col.names = F, row.names = F, quote = F, sep="\t")#for PU (1st part)
table_valid_goes<-table(go$V2)
table_valid_goes<-table_valid_goes[table_valid_goes>=minGOsize & table_valid_goes<=maxGOsize]
length(table_valid_goes)
table_valid_goes<-table_valid_goes[order(table_valid_goes)]
write.table(names(table_valid_goes), file="/home/bueno002/chi35_1GO/additional/take_138goes", col.names = F, row.names = F, quote = F, sep="\t")

#exclude GO terms if they are too similar. This is in case the 138 cannot be run
goes<-read.table("/home/bueno002/chi35_1GO/additional/take_138goes")
goes<-as.character(goes$V1)
library(GOSim)
Matrix_sim_Goes<-getTermSim(goes, method = "Lin", verbose = FALSE)
library(reshape2)
strongly<-subset(melt(Matrix_sim_Goes), value > .85)#exclude GOES that have similarity above 0.85. For simplicity we do not pay attention to pairs
dim(strongly)
strongly<-strongly[as.character(strongly$Var1) != as.character(strongly$Var2),]
dim(strongly)
strongly<-as.character(unique(append(as.character(strongly$Var1),as.character(strongly$Var2))))
length(strongly)
table_valid_goes<-table(go$V2)
table_valid_goes<-table_valid_goes[table_valid_goes>=minGOsize & table_valid_goes<=maxGOsize]
table_valid_goes<-table_valid_goes[!names(table_valid_goes) %in% strongly & table_valid_goes != 0]
length(table_valid_goes)# #GOterms
table_valid_goes<-table_valid_goes[order(table_valid_goes)]
write.table(table_valid_goes, file="/home/bueno002/chi35_1GO/additional/take_30goes_table", col.names = F, row.names = F, quote = F, sep="\t")
write.table(names(table_valid_goes), file="take_30goes", col.names = F, row.names = F, quote = F, sep="\t")

#prepare the file of 108GO terms
file138<-read.table("/home/bueno002/chi35_1GO/additional/take_138goes")
file30<-read.table("/home/bueno002/chi35_1GO/take_30goes")
file108<-file138[!as.character(file138$V1) %in% as.character(file30$V1),]
file108<-data.frame(file108)
go<-read.table("/home/bueno002/chi35_1GO/go_valid.tsv")
gomy<-go[go$V2 %in% file108$file108,]
Ta<-table(gomy$V2)
Ta<-Ta[Ta !=0]
Tadf<-as.data.frame(Ta)
Tadf$V2<-rownames(Tadf)
Tadf<-Tadf[,c(2,1)]
Tadf<-Tadf[with(Tadf, order(Ta)), ]
write.table(Tadf$V2, file="take_108goes", col.names = F, row.names = F, quote = F, sep="\t")
write.table(Tadf, file="/home/bueno002/chi35_1GO/additional/take_108goes_table", col.names = F, row.names = F, quote = F, sep="\t")



