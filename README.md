<img src="https://user-images.githubusercontent.com/52681915/117520421-7b0b2480-af7e-11eb-8456-9dd8280120f0.png" width="1200" height="300">

# My script to run ENM using Maxent alghoritm!

#### README work in progress but feel free to explore the script<br><br>
I've tried to comment the code as much as possible but you can write me if you have any doubts or suggestions @didelphisaurita 

It is quite a simple script, nothing much sofisticated but it works :) I believe it can be particularly **interesting for beginners and intermediate level R users** as it doesn't have lots of complicated functions, if any, it's pretty straightfoward. You may have to manually install some of the packages, I had some trouble installing the ones using devtools:install_github() <br><br>
For my project i used current climate and four future scenarios, so, for each scenario there's a corresponding block of code. 

1) If you want to use less scenarios you just have to delete the corresponding blocks of code 

2) if you want to run more scenarios you just have to copy, paste and change object's names so it doesn't overwrite other scenario's objects.


The basic requirements to run the script is to **set the variables and records path and it's good to go!** You should look into the tuning parameters, though, I will mention them latter<br><br>
To run the script you'll need a data folder in your working directory/root folder, the result folders are created automatically. The structure of data folder is as follows (you can also see sdmfolder_example.zip file):


<details><summary>Structure:</summary>
    <pre>

```console

├── sdm_example
│   └── data
│       ├── elev
|       |   └── elevation.tif
│       ├── raster
│       │   ├── current
|       |   |   └── variables.tif
│       │   ├── RCP26
|       |   |   └── variables.tif
│       │   ├── RCP45
|       |   |   └── variables.tif
│       │   ├── RCP60
|       |   |   └── variables.tif
│       │   └── RCP85
|       |   |   └── variables.tif
│       └── records
            └── records.csv
```
</pre>
   </details>

**Elevation is actually optional**. If you don't want to extract elevation, you can remove/comment the part of the script that computes elevation or just run it anyway, you'll get lots of error messages but everything else should work just fine.

I believe that the parameters that you should pay the most attention while fine tuning are the following (but check the whole script):


<details><summary>Parameters:</summary>
    <pre>


```ruby
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
376 buffered.mcp.records <- raster::buffer(mcp.records, width = 200*km 
```

</pre>
   </details>
   
  I chose a KFold=5 partioning of the data so there are 5 models for each scenario/species.
  
The output consists of:
 ```
1.Records and background points with a KFold ID
2.Rdata on each model
3.Tuning parameters for each model
4.Continous Maxent models
5.Variance of the continous models
6.Metrics of evaluation:CBI, TSS and AUC
7.Threshold values
8.CBI weighted mean ensemble model
9.Thresholded model
10.Area and elevation of the thresholded models
11.Log file with species names, number of records, metrics and threshold values
```

  
I use CBI as the main metric and to weight means, and TSS and AUC as better than random metrics.
  
