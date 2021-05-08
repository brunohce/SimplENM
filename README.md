<img src="https://user-images.githubusercontent.com/52681915/117520421-7b0b2480-af7e-11eb-8456-9dd8280120f0.png" width="400" height="250">



**My script to run ENM using Maxent alghoritm!**

I've tried to comment the code as much as possible but you can write me if you have any doubts or suggestions @didelphisaurita 


It is quite a simple script, nothing much sofisticated but it works :) I believe it can be particularly **interesting for beginners and intermediate level R users** as it doesn't have lots of complicated functions, if any, it's pretty straightfoward. 


For my project i used current climate and four future scenarios, so:

1) If you want to use less scenarios you just have to delete the corresponding blocks of code 

2) if you want to run more scenarios you just have to copy, paste and change object's names so it doesn't overwrite other scenario's objects.


All you have to do is **set the variables and records path and it's good to go!** You should look into the tuning parameters, though, specially lines:


```
# Number of background points, in my case 10K
113 randomBgSites <- dismo::randomPoints(current, 10000)

#Minimum, maximum and intervals of master regularization (regMult)
#Classes of features (classes)
185 tunedModel <- trainMaxNet(data=trainData,
                            regMult= c(seq(1, 4, by = 0.5)),
                            verbose=F,
                            classes = "lqh",
                            testClasses=TRUE,
                            clamp=T,
191                         out = c('model', 'tuning'))

#Threshold of suitability, in my case 5% lowest values = 0.95 
242 p95 <- round(length(occPredVals) * 0.95)

#Distance from species MCP to cut off, in my case 200 km
376 buffered.mcp.records <- raster::buffer(mcp.records, width = 200*km )
```



To run the script you need a root folder with the following structure


<details><summary>Structure:</summary>
    <pre>

```console

├── data
│   ├── elev
│   │   └── elevation.tif
│   ├── raster
│   │   ├── current
│   │   │   ├── variables.tif
│   │   ├── RCP26
│   │   │   ├── variables.tif
│   │   ├── RCP45
│   │   │   ├── variables.tif
│   │   ├── RCP60
│   │   │   ├── variables.tif
│   │   └── RCP85
│   │   │   ├── variables.tif
│   └── records
│       ├── records_species1.csv

```
 </pre>
   </details>
   
Elevation is actually optional. If you don't want to extract elevation, you can remove/comment the part of the script that computes elevation or just run it anyway, you'll get lots of error messages but everything else should work just fine.
   
