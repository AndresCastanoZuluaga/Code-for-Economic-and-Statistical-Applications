# clean all
rm(list=ls(all=TRUE))# for remove all the objects
# Ask for help
?plot
?googleVis
# generar una variable
a <-1 # option 1
c=2 # option 2
# operators
3/2
3*2
b <- 3/2
b
# for sequences
w <- 1:10
z <- w*w
z
v <- (1:10)+2
v
# to make a plot
?plot
plot(x=w, y=z)
plot(x=w, y=z, main = "My favorite plot")
# change one specific element in the sequence
z[5]
z[15]
z[5] <- 100
