getwd()
setwd("C:/Users/asus/Desktop/COVID Bulletin Research/KA trace analysis ongoing/clustersinr")
data1 <- read.csv("ann2.csv")
data2 <- read.csv("contacts.csv")
data1ph <- read.csv("ann2_pharma.csv")
data1tj <- read.csv("ann2_tj.csv")
data2cl <- read.csv("contactswithevents.csv")
library(epicontacts)
library(visNetwork)
library(fitdistrplus)

#Loading epicontacts data and defining clusters
x <- make_epicontacts(data1, data2, id = 1L, from = 1L, to = 2L,directed = TRUE)

xph <- make_epicontacts(data1ph, data2cl, id = 1L, from = 1L, to = 2L,directed = TRUE)
xph <- thin(xph,2)

xtj <- make_epicontacts(data1tj, data2cl, id = 1L, from = 1L, to = 2L,directed = TRUE)
xtj <- thin(xtj,2)

clusters <- get_clusters(x, output="data.frame")
write.csv(clusters, "clusters.csv")
truncated <- subset(x, x$linelist$dt_conf<=13-Jun)
sse <- subset(x, cs_min=10)
bellary <- subset(x,cs_min = 100)
second <- subset(x, cs=61)
third <- subset(x, cs=60)
fourth <- subset(x, cs=59)
fifth <- subset(x, cs=52)

#Figures

figbellary <- vis_epicontacts(bellary, 
                         node_color =  "age_class",
                         label= c("id"),
                         col_pal=spectral, 
                         edge_1col_pal = fac2col,
                         edge_color = "from", 
                         edge_label= "Reason",
                         NA_col = "#000000" , 
                         main="The Bellary Cluster (Karnataka, India)", submain="Index case: Case 4350 of Karnataka || Total size=221 cases || Reproduction number(R)=0.99 || Overdispersion metric(k)=0.17 || Hover, zoom in or out, and click on a case for more details.", footer="Gupta et al (2020)")
figbellary
visPhysics(figbellary, solver= "barnesHut", barnesHut= list(gravitationalConstant=-5000))


figph <- vis_epicontacts(xph, 
                       node_color =  "City",
                       label= c("id"),
                       col_pal=spectral, 
                       edge_1col_pal = fac2col,
                       edge_color = "from", 
                       edge_label= "Reason",
                       NA_col = "#000000" , 
                       main="The Pharmaceutical Company Cluster (Karnataka, India)", submain="Origin (Red Circle): A Pharmaceutical Company, Nanjangud City, Mysore District, Karnataka || Total size=76 cases || Reproduction number(R)=0.70 || Overdispersion metric(k)=0.17 || Hover, zoom in or out, and click on a case for more details.", footer="Gupta et al (2020)")
figph
visPhysics(figph, solver= "barnesHut", barnesHut= list(gravitationalConstant=-5000))
visEdges(fig, smooth = FALSE)
visIgraphLayout(fig)
graph3D(sse,node_size = 0.5, edge_size = 9)

figtj <- vis_epicontacts(xtj, 
                         node_color =  "age_class",
                         legend=TRUE,
                         label= c("id"),
                         col_pal=spectral, 
                         edge_col_pal = fac2col,
                         edge_color = "from", 
                         edge_label= "Reason",
                         NA_col = "#000000" , 
                         main="The Tablighi Jamaat Cluster (Karnataka, India)", submain="Origin (Red Circle): Tablighi Jamaat Convention, Delhi || Total size=97 cases || Reproduction number(R)=0.77 || Overdispersion metric(k)=0.21 || Hover, zoom in or out, and click on a case for more details.", footer="Gupta et al (2020)")
visPhysics(figtj, solver= "barnesHut", barnesHut= list(gravitationalConstant=-5000))
figtj


#Defining clusters without event exposure linkage
tj <- subset_clusters_by_id(x, c(114,
                                 115,
                                 116,
                                 117,
                                 118,
                                 119,
                                 120,
                                 121,
                                 122,
                                 123,
                                 124,
                                 126,
                                 127,
                                 128,
                                 143,
                                 144,
                                 147,
                                 148,
                                 149,
                                 150,
                                 151,
                                 163))
tj <- thin(tj,2) 
pharma <- subset_clusters_by_id(x, c(52,
                                     77,
                                     78,
                                     79,
                                     80,
                                     81,
                                     85,
                                     86,
                                     87,
                                     88,
                                     103,
                                     104,
                                     159,
                                     264,
                                     265,
                                     266,
                                     267,
                                     268,
                                     269,
                                     270,
                                     271,
                                     272,
                                     303,
                                     311))
pharma <- thin (pharma,2)

#Fitting for R/k
fit <- fitdist(x$linelist$children_all, "nbinom", method = "mle")
fitbellary <- fitdist(bellary$linelist$children_all, "nbinom", method = "mle")
fit2 <- fitdist(second$linelist$children_all, "nbino", method = "mle")
fit3 <- fitdist(third$linelist$children_all, "nbinom", method = "mle")
fit4 <- fitdist(fourth$linelist$children_all, "nbinom", method = "mle")
fit5 <- fitdist(fifth$linelist$children_all, "nbinom", method = "mle")
fitsse <- fitdist(sse$linelist$children_all, "nbinom", method = "mle")
fittj <- fitdist(tj$linelist$children_all, "nbinom", method = "mle")
fitpharma <- fitdist(pharma$linelist$children_all, "nbinom", method = "mle")
x <- thin()
